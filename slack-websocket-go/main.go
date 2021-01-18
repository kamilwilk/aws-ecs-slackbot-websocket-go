package main

import (
	"os"
	"strings"

	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"

	"github.com/slack-go/slack"
	"github.com/slack-go/slack/slackevents"
	"github.com/slack-go/slack/socketmode"
)

func main() {
	// Pretty printed logs for local development
	//log.Logger = log.Output(zerolog.ConsoleWriter{Out: os.Stderr})

	_, present := os.LookupEnv("DEBUG")

	if present {
		zerolog.SetGlobalLevel(zerolog.DebugLevel)
	} else {
		zerolog.SetGlobalLevel(zerolog.InfoLevel)
	}

	zerolog.TimeFieldFormat = zerolog.TimeFormatUnix
	appToken := os.Getenv("SLACK_APP_TOKEN")
	if appToken == "" {
		log.Fatal().Msg("SLACK_APP_TOKEN must be set.")
	}

	if !strings.HasPrefix(appToken, "xapp-") {
		log.Fatal().Msg("SLACK_APP_TOKEN must have the prefix \"xapp-\".")
	}

	botToken := os.Getenv("SLACK_BOT_TOKEN")
	if botToken == "" {
		log.Fatal().Msg("SLACK_BOT_TOKEN must be set.\n")
	}

	if !strings.HasPrefix(botToken, "xoxb-") {
		log.Fatal().Msg("SLACK_BOT_TOKEN must have the prefix \"xoxb-\".")
	}

	api := slack.New(
		botToken,
		slack.OptionDebug(false),
		slack.OptionAppLevelToken(appToken),
	)

	client := socketmode.New(
		api,
		socketmode.OptionDebug(false),
	)

	go func() {
		for evt := range client.Events {
			log.Debug().Interface("event", evt).Msg("Received Event")

			switch evt.Type {
			//Socket Mode Client Events
			case socketmode.EventTypeConnecting:
				log.Info().Msg("Connecting to Slack with Socket Mode...")
			case socketmode.EventTypeInvalidAuth:
				log.Fatal().Msg("Invalid Auth to Slack with Socket Mode")
			case socketmode.EventTypeConnectionError:
				log.Error().Msg("Connection failed. Retrying later...")
			case socketmode.EventTypeConnected:
				log.Info().Msg("Connected to Slack with Socket Mode")
			case socketmode.EventTypeIncomingError:
				log.Error().Msg(string(evt.Type))
			case socketmode.EventTypeErrorWriteFailed:
				log.Error().Msg(string(evt.Type))
			case socketmode.EventTypeErrorBadMessage:
				log.Error().Msg(string(evt.Type))

			//Slack Events
			case socketmode.EventTypeHello:
				log.Info().Msg("Received Hello from Slack Socket Mode")

			case socketmode.EventTypeDisconnect:
				log.Info().Msg("Received Disconnect from Slack Socket Mode")

			case socketmode.EventTypeEventsAPI:
				eventsAPIEvent, ok := evt.Data.(slackevents.EventsAPIEvent)
				if !ok {
					log.Debug().Interface("event", evt).Msg("Ignored Event")
					continue
				}
				log.Debug().Interface("event", eventsAPIEvent).Msg("Event Received")
				client.Ack(*evt.Request)

			case socketmode.EventTypeInteractive:
				interactionCallback, ok := evt.Data.(slack.InteractionCallback)
				if !ok {
					log.Debug().Interface("event", evt).Msg("Ignored Event")
					continue
				}
				log.Debug().Interface("event", evt).Msg("Interaction Callback Received")
				client.Ack(*evt.Request)

				switch interactionCallback.Type {
				case slack.InteractionTypeBlockActions:
					log.Debug().Msg("Button Pressed")

					var msgText slack.MsgOption
					switch interactionCallback.ActionCallback.BlockActions[0].ActionID {
					case "pressme":
						msgText = slack.MsgOptionText("You're the best! :slightly_smiling_face:", false)
					case "dontpressme":
						msgText = slack.MsgOptionText("Why would you do that?! :angry:", false)
					default:
						msgText = slack.MsgOptionText("Well I'm not sure how we ended up here.. :thinking_face:", false)
					}

					_, _, err := api.PostMessage(interactionCallback.Channel.ID, slack.MsgOptionReplaceOriginal(interactionCallback.ResponseURL), msgText)
					if err != nil {
						log.Error().Err(err).Msg("Failed to Post Message")
					}

				default:
					log.Error().Interface("event", evt).Msg("Unsupported Interaction Callback Type")
				}

			case socketmode.EventTypeSlashCommand:
				slashCommand, ok := evt.Data.(slack.SlashCommand)
				if !ok {
					log.Debug().Interface("event", evt).Msg("Ignored Event")
					continue
				}
				log.Debug().Interface("event", slashCommand).Msg("Slash Command Received")

				payload := map[string]interface{}{
					"blocks": []slack.Block{
						slack.NewSectionBlock(
							&slack.TextBlockObject{
								Type: slack.MarkdownType,
								Text: "Choose wisely...",
							},
							nil,
							nil,
						),
						slack.NewActionBlock("",
							slack.NewButtonBlockElement(
								"pressme",
								"pressemevalue",
								&slack.TextBlockObject{
									Type: slack.PlainTextType,
									Text: "Press Me",
								},
							).WithStyle(slack.StylePrimary),
							slack.NewButtonBlockElement(
								"dontpressme",
								"dontpressmevalue",
								&slack.TextBlockObject{
									Type: slack.PlainTextType,
									Text: "Don't Press Me",
								},
							).WithStyle(slack.StyleDanger),
						),
					},
				}
				client.Ack(*evt.Request, payload)

			default:
				log.Error().Interface("event", evt).Msg("Unexpected Event")
			}
		}
	}()

	client.Run()
}

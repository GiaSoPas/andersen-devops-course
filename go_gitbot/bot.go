package main

import (
	"log"

	tgbotapi "github.com/go-telegram-bot-api/telegram-bot-api"
)

func main() {
	bot, err := tgbotapi.NewBotAPI("1868882835:AAHBWO30JccYhZMBD2KqCmCFKV3UxU19ki4")
	if err != nil {
		log.Panic(err)
	}

	bot.Debug = true

	log.Printf("Authorized on account %s", bot.Self.UserName)

	u := tgbotapi.NewUpdate(0)
	u.Timeout = 60

	updates, err := bot.GetUpdatesChan(u)

	for update := range updates {
		if update.Message == nil {
			continue
		}

		log.Printf("[%s] %s", update.Message.From.UserName, update.Message.Text)

		if update.Message.IsCommand() {
			msg := tgbotapi.NewMessage(update.Message.Chat.ID, "")
			switch update.Message.Command() {
			case "tasks":
				msg.Text = "1. Ansible task\n2. One-liner to script task\n3. Git api script task\n4. Telegram bot on golang"
			case "aboutme":
				msg.Text = "https://github.com/nastasyafedotovna/andersen-devops-course/blob/main/aboutMyself/aboutme.md"
			case "tilblog":
				msg.Text = "https://github.com/nastasyafedotovna/andersen-devops-course/blob/main/TIL/til.md"
			case "task1":
				msg.Text = "https://github.com/nastasyafedotovna/andersen-devops-course/tree/main/ansible_task"
			case "task2":
				msg.Text = "https://github.com/nastasyafedotovna/andersen-devops-course/tree/main/netstat_script"
			case "task3":
				msg.Text = "https://github.com/nastasyafedotovna/andersen-devops-course/tree/main/git_api"
			case "task4":
				msg.Text = "https://github.com/nastasyafedotovna/andersen-devops-course/tree/main/go_gitbot"
			default:
				msg.Text = "I don't know that command"
			}
			bot.Send(msg)
		}

	}
}

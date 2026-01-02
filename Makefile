# Default configuration values (can be overridden via make arguments or environment)
HTTP_PORT ?= 8080
HTTP_HOST ?= 127.0.0.1
FFMPEG_PATH ?= /opt/homebrew/bin/ffmpeg

build:
	swift build

release:
	swift build -c release

test:
	swift test --parallel

clean:
	rm -rf .build

install: release
	@mkdir -p $(HOME)/.bin
	install ./.build/release/TTSServer $(HOME)/.bin/TTSServer

service: install
	@echo "Creating launchd service..."
	@mkdir -p $(HOME)/Library/LaunchAgents
	@printf '%s\n' '<?xml version="1.0" encoding="UTF-8"?>' \
	'<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' \
	'<plist version="1.0">' \
	'<dict>' \
	'    <key>Label</key>' \
	'    <string>HatsumeAI.TTSServer</string>' \
	'    <key>ProgramArguments</key>' \
	'    <array>' \
	'        <string>$(HOME)/.bin/TTSServer</string>' \
	'    </array>' \
	'    <key>EnvironmentVariables</key>' \
	'    <dict>' \
	'        <key>HTTP_PORT</key>' \
	'        <string>$(HTTP_PORT)</string>' \
	'        <key>HTTP_HOST</key>' \
	'        <string>$(HTTP_HOST)</string>' \
	'        <key>FFMPEG_PATH</key>' \
	'        <string>$(FFMPEG_PATH)</string>' \
	'    </dict>' \
	'    <key>RunAtLoad</key>' \
	'    <true/>' \
	'    <key>KeepAlive</key>' \
	'    <true/>' \
	'</dict>' \
	'</plist>' \
	> $(HOME)/Library/LaunchAgents/HatsumeAI.TTSServer.plist
	@echo "Service installed to: $(HOME)/Library/LaunchAgents/HatsumeAI.TTSServer.plist"
	@echo ""
	@echo "Configuration:"
	@echo "  HTTP_PORT=$(HTTP_PORT)"
	@echo "  HTTP_HOST=$(HTTP_HOST)"
	@echo "  FFMPEG_PATH=$(FFMPEG_PATH)"
	@echo ""
	@echo "To enable and start the service:"
	@echo "  launchctl load $(HOME)/Library/LaunchAgents/HatsumeAI.TTSServer.plist"
	@echo ""
	@echo "To disable and stop the service:"
	@echo "  launchctl unload $(HOME)/Library/LaunchAgents/HatsumeAI.TTSServer.plist"
	@echo ""
	@echo "To check service status:"
	@echo "  launchctl list | grep TTSServer"
	@echo ""

start: service
	launchctl load $(HOME)/Library/LaunchAgents/HatsumeAI.TTSServer.plist
	@echo "Service started..."
	@echo ""

stop: service
	launchctl unload $(HOME)/Library/LaunchAgents/HatsumeAI.TTSServer.plist
	@echo "Service stopped..."
	@echo ""

restart: stop start



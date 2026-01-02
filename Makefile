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
	'    <key>RunAtLoad</key>' \
	'    <true/>' \
	'    <key>KeepAlive</key>' \
	'    <true/>' \
	'</dict>' \
	'</plist>' \
	> $(HOME)/Library/LaunchAgents/HatsumeAI.TTSServer.plist
	@echo "Service installed to: $(HOME)/Library/LaunchAgents/HatsumeAI.TTSServer.plist"
	@echo ""
	@echo "To enable and start the service:"
	@echo "  launchctl load $(HOME)/Library/LaunchAgents/HatsumeAI.TTSServer.plist"
	@echo ""
	@echo "To disable and stop the service:"
	@echo "  launchctl unload $(HOME)/Library/LaunchAgents/HatsumeAI.TTSServer.plist"
	@echo ""
	@echo "To check service status:"
	@echo "  launchctl list | grep TTSServer"

start: service
	launchctl load $(HOME)/Library/LaunchAgents/HatsumeAI.TTSServer.plist

stop: service
	launchctl unload $(HOME)/Library/LaunchAgents/HatsumeAI.TTSServer.plist

restart: stop start



# Makefile for managing MCP server Docker containers

SUBMODULES := github notion

.PHONY: up down status start-% stop-%

up:
	@for sub in $(SUBMODULES); do \
		if [ -f mcps/$$sub/docker-compose.yml ]; then \
			echo "Starting $$sub with docker-compose..."; \
			(cd mcps/$$sub && docker-compose up -d); \
		elif [ -f mcps/$$sub/docker-image.txt ] && [ -f mcps/$$sub/version.txt ]; then \
			echo "Pulling and running $$sub from registry..."; \
			IMAGE=$$(cat mcps/$$sub/docker-image.txt); \
			VERSION=$$(cat mcps/$$sub/version.txt); \
			FULL_IMAGE="$$IMAGE:$$VERSION"; \
			ENV_FILE=env/.env.$$sub; \
			echo "Using image: $$FULL_IMAGE"; \
			if [ -f $$ENV_FILE ]; then \
				ENV_OPTS=$$(sed '/^\s*#/d;/^\s*$$/d;s/^/-e /' $$ENV_FILE | xargs); \
				docker pull $$FULL_IMAGE && \
				docker run -d --name mcp-$$sub-container -p 8080:8080 $$ENV_OPTS $$FULL_IMAGE; \
			else \
				docker pull $$FULL_IMAGE && \
				docker run -d --name mcp-$$sub-container -p 8080:8080 $$FULL_IMAGE; \
			fi; \
		elif [ -f mcps/$$sub/Dockerfile ]; then \
			echo "Building and running $$sub Dockerfile..."; \
			docker build -t mcp-$$sub-image mcps/$$sub; \
			ENV_FILE=env/.env.$$sub; \
			if [ -f $$ENV_FILE ]; then \
				ENV_OPTS=$$(sed '/^\s*#/d;/^\s*$$/d;s/^/-e /' $$ENV_FILE | xargs); \
				docker run -d --name mcp-$$sub-container -p 8080:8080 $$ENV_OPTS mcp-$$sub-image; \
			else \
				docker run -d --name mcp-$$sub-container -p 8080:8080 mcp-$$sub-image; \
			fi; \
		else \
			echo "No Dockerfile, docker-image.txt, or docker-compose.yml found for $$sub"; \
		fi; \
	done

down:
	@for sub in $(SUBMODULES); do \
		if [ -f mcps/$$sub/docker-compose.yml ]; then \
			echo "Stopping $$sub with docker-compose..."; \
			(cd mcps/$$sub && docker-compose down); \
		else \
			echo "Stopping and removing container for $$sub..."; \
			docker stop mcp-$$sub-container || true; \
			docker rm mcp-$$sub-container || true; \
			docker rmi mcp-$$sub-image || true; \
		fi \
	done

status:
	@docker ps --filter "name=mcp-" | grep -E "mcp-($(shell echo $(SUBMODULES) | tr ' ' '|'))"

start-%:
	@if [ -f mcps/$*/docker-compose.yml ]; then \
		echo "Starting $* with docker-compose..."; \
		(cd mcps/$* && docker-compose up -d); \
	elif [ -f mcps/$*/docker-image.txt ] && [ -f mcps/$*/version.txt ]; then \
		echo "Pulling and running $* from registry..."; \
		IMAGE=$$(cat mcps/$*/docker-image.txt); \
		VERSION=$$(cat mcps/$*/version.txt); \
		FULL_IMAGE="$$IMAGE:$$VERSION"; \
		ENV_FILE=env/.env.$*; \
		echo "Using image: $$FULL_IMAGE"; \
		if [ -f $$ENV_FILE ]; then \
			ENV_OPTS=$$(sed '/^\s*#/d;/^\s*$$/d;s/^/-e /' $$ENV_FILE | xargs); \
			docker pull $$FULL_IMAGE && \
			docker run -d --name mcp-$*-container -p 8080:8080 $$ENV_OPTS $$FULL_IMAGE; \
		else \
			docker pull $$FULL_IMAGE && \
			docker run -d --name mcp-$*-container -p 8080:8080 $$FULL_IMAGE; \
		fi; \
	elif [ -f mcps/$*/Dockerfile ]; then \
		echo "Building and running $* Dockerfile..."; \
		docker build -t mcp-$*-image mcps/$*; \
		ENV_FILE=env/.env.$*; \
		if [ -f $$ENV_FILE ]; then \
			ENV_OPTS=$$(sed '/^\s*#/d;/^\s*$$/d;s/^/-e /' $$ENV_FILE | xargs); \
			docker run -d --name mcp-$*-container -p 8080:8080 $$ENV_OPTS mcp-$*-image; \
		else \
			docker run -d --name mcp-$*-container -p 8080:8080 mcp-$*-image; \
		fi; \
	else \
		echo "No Dockerfile, docker-image.txt, or docker-compose.yml found for $*"; \
	fi

stop-%:
	@if [ -f mcps/$*/docker-compose.yml ]; then \
		echo "Stopping $* with docker-compose..."; \
		(cd mcps/$* && docker-compose down); \
	else \
		echo "Stopping and removing container for $*..."; \
		docker stop mcp-$*-container || true; \
		docker rm mcp-$*-container || true; \
		docker rmi mcp-$*-image || true; \
	fi

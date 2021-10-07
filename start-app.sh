ENV_FILE=".env"
ENV_EXAMPLE_FILE=".env.example"

if ! test -f $ENV_FILE; then
	if test -f $ENV_EXAMPLE_FILE; then
		read -r -p "$ENV_FILE not found. Do you wanna create one by copying '$ENV_EXAMPLE_FILE'? [y/N]" response

		response=${response,,}
		if [[ "$response" =~ ^(yes|y)$ ]]; then
			cp $ENV_EXAMPLE_FILE $ENV_FILE
		else
			echo "Error: .env not found. (You should create it.)"
			exit 1
		fi
	else
		echo "Error: .env.example not found."
		exit 1
	fi
fi

# export env variables
export $(cat .env | sed 's/#.*//g' | xargs)

(
	(docker -v || echo "Docker not found.") &&
	(docker-compose up -d || echo "Make sure docker is running.") &&
	docker exec todo_ls_backend npm test &&
	docker exec todo_ls_backend npm run migrate &&
	docker exec todo_ls_backend npm run seed &&
	echo "App is now available at http://localhost:${FRONTEND_CONTAINER_PORT}"
) || echo "If you had started the app before, you should shut down the containers, remove the images and run this again."
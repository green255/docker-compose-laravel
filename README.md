# docker-compose-laravel
A pretty simplified Docker Compose workflow that sets up a LEMP network of containers for local Laravel development. You can view the full article that inspired this repo [here](https://dev.to/aschmelyun/the-beauty-of-docker-for-local-laravel-development-13c0).

## Usage

### Setting up the Docker configuration 
1. Have [Docker installed](https://docs.docker.com/docker-for-mac/install/) and running
2. Clone this repo into your project's directory ```git clone https://github.com/green255/docker-compose-laravel.git <my project dir>```
3. Ensure that the docker environment variables (<project root>/.env) are correct for your setup.
4. With your terminal in the project directory spin up the containers for the application by running `docker-compose up --build nginx`.  
   (Bringing up the Docker Compose network with `nginx` instead of just using `up`, ensures that only our site's containers are brought up at the start instead of all of the command containers as well)

### Migrating Project's Code
Before following either of the subsequent paths you will need to run the following:  
```chmod 755 setup.sh```

#### Migrate a Fresh Laravel Instance
1. Run ```composer create-project --ignore-platform-reqs --remove-vcs laravel/laravel laravel "^9.0"```  
(substitute your laravel version of choice)
2. Run ```./setup.sh``` 

#### Migrate an Existing Project's Codebase
1. Add the .env variables from your project into the present .env file
2. Clone your project into a folder named ```laravel```
3. Run ```./setup.sh```  
Note: If your project requires a version of php less than 8, then ```dockerfiles/php.dockerfile``` will need to be modified to reflect that

### Service Containers
Three additional containers are included that handle Composer, NPM, and Artisan commands *without* having to have these platforms installed on your local computer. Use the following command examples from your project root, modifying them to fit your particular use case.

- `docker-compose run --rm composer update`
- `docker-compose run --rm npm run dev`
- `docker-compose run --rm artisan migrate`  
(*remember your laravel database credentials must match those used when the docker containers were built - refer to the laravel & docker sections in .env*)

### Port Availabilty
The following are built for our web server, with their exposed ports detailed:
- **nginx** - `:80 & :443`
- **mysql** - `:3306`
- **php** - `:9000`
- **redis** - `:6379`
- **mailhog** - `:8025`

## Permissions Issues

If you encounter any issues with filesystem permissions while visiting your application or running a container command, try completing one of the sets of steps below.

**If you are using your server or local environment as the root user:**

- Bring any container(s) down with `docker-compose down`
- Rename `docker-compose.root.yml` file to `docker-compose.root.yml`, replacing the previous one
- Re-build the containers by running `docker-compose build --no-cache`

**If you are using your server or local environment as a user that is not root:**

- Bring any container(s) down with `docker-compose down`
- In your terminal, run `export UID=$(id -u)` and then `export GID=$(id -g)`
- If you see any errors about readonly variables from the above step, you can ignore them and continue
- Re-build the containers by running `docker-compose build --no-cache`

Then, either bring back up your container network or re-run the command you were trying before, and see if that fixes it.

## Persistent MySQL Storage

Without persistent storage, whenever you bring down the Docker network, your MySQL data will be removed after the containers are destroyed. If you would like to have persistent data that remains after bringing containers down and back up, do the following:

1. Create a `mysql` folder in dockerfiles/ alongside the `nginx` and `src` folders.
2. Under the mysql service in your `docker-compose.yml` file, add the following lines:

```
volumes:
  - ./dockerfiles/mysql:/var/lib/mysql
```

## Using BrowserSync with Laravel Mix

If you want to enable the hot-reloading that comes with Laravel Mix's BrowserSync option, you'll have to follow a few small steps. First, ensure that you're using the updated `docker-compose.yml` with the `:3000` and `:3001` ports open on the npm service. Then, add the following to the end of your Laravel project's `webpack.mix.js` file:

```javascript
.browserSync({
    proxy: 'site',
    open: false,
    port: 3000,
});
```

From your terminal window at the project root, run the following command to start watching for changes with the npm container and its mapped ports:

```bash
docker-compose run --rm --service-ports npm run watch
```

That should keep a small info pane open in your terminal (which you can exit with Ctrl + C). Visiting [localhost:3000](http://localhost:3000) in your browser should then load up your Laravel application with BrowserSync enabled and hot-reloading active.

## MailHog

The current version of Laravel (8 as of today) uses MailHog as the default application for testing email sending and general SMTP work during local development. Using the provided Docker Hub image, getting an instance set up and ready is simple and straight-forward. The service is included in the `docker-compose.yml` file, and spins up alongside the webserver and database services.

To see the dashboard and view any emails coming through the system, visit [localhost:8025](http://localhost:8025) after running `docker-compose up -d site`.

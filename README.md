# docker-compose-laravel
A pretty simplified Docker Compose workflow that sets up a LEMP network of containers for local Laravel development. You can view the full article that inspired this repo [here](https://dev.to/aschmelyun/the-beauty-of-docker-for-local-laravel-development-13c0).

## Usage

### Setting up the Docker configuration
1. Have [Docker installed](https://docs.docker.com/docker-for-mac/install/) and running
2. Clone this repo into your project's directory ```git clone https://github.com/green255/docker-compose-laravel.git --branch php7-4 <my project dir>```
3. Ensure that the docker environment variables (<project root>/setup.env) are correct for your setup.

### Incorporating Project's Code
Before following either of the subsequent paths you will need to run the following:  
1. ```chmod 755 setup.sh```
2. rename setup.env to .env

#### Fresh Laravel Instance
1. Run ```docker-composer run --rm composer create-project --remove-vcs laravel/laravel laravel "8.x"```  
   (Note: Laravel version 8 is the last that supports php 7)

#### Migrate an Existing Project's Codebase
1. Add the .env variables from your project into setup.env
2. Clone your project into a folder named ```laravel```
   Note: If your project requires a version of php other than 8.1, check the other branches of this repo. If your version does not exist, then ```dockerfiles/php.dockerfile``` will need to be modified to incorporate your version.

#### Finishing Migration
1. Run ```./setup.sh``` - after running this file can be deleted

#### Starting Docker
With your terminal at the project root spin up the containers for the application by running:  
`docker-compose up --build`  

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

Persistent database storage is enabled out of the box in this configuration. The source volume by default is ```./dockerfiles/mysql``` and otherwise can be found in the mysql section of ```docker-compose.yml```.
To purge this data simply delete the file(s) within that directory, but leave the .gitignore file.

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

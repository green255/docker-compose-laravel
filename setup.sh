# migrate laravel source code to project root
rm ./laravel/.gitignore
rm ./laravel/.env
rm ./laravel/README.md
mv ./laravel/* ./
mv ./laravel/.* ./
rm -d ./laravel
docker-compose run --rm artisan key:generate

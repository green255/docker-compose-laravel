# migrate laravel source code to project root
## this script will output warnings but does successfully perform the desired task
rm ./laravel/.gitignore
rm ./laravel/.env
rm ./laravel/README.md
mv ./laravel/* ./
mv ./laravel/.* ./
rm -d ./laravel
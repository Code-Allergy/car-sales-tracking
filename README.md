## Installation

### Dependencies
You must have npm installed on your system. Docker is optionally required if you would like to host the database instance locally. There are no other external dependencies, and everything required is managed through npm.

### Project Setup
To get started with our project, clone it locally to your system.

Then, navigate to the root folder of our project and run the command:
```shell
npm i
```
This will install all required dependencies.

Now, the project is ready to build and run. But first we will set up a database instance for our application.

Ideally for simplicity, we recommend you register an account on Supabase and create a project.
If you would like to avoid creating an account, you can instead self-host a Supabase instance locally 
on your own system. Instructions for this follow directly below. 

Otherwise, skip ahead to the [Supabase.com setup](#supabasecom-setup) section

### Supabase Local Deployment

If you decide instead to host the instance locally, follow the directions
[here](https://supabase.com/docs/guides/self-hosting/docker) first to get a local deployment. You will need docker, as they use docker compose to 
run all their services. Run these commands within a folder external to our project, as to not cause
issues with linting.

You will then want to replace the following environment variables in the root file .env:

`NEXT_PUBLIC_SUPABASE_URL`: `http://localhost:8000/`

`NEXT_PUBLIC_SUPABASE_ANON_KEY`: Inside the .example.env file you copied as part of setting up supabase.

`SUPABASE_SERVICE_KEY`: Inside the .example.env file you copied as part of setting up supabase.


You will also need to make note of the following in the .example.env, these are used to log in to the web portal:

`DASHBOARD_USERNAME`

`DASHBOARD_PASSWORD`

With those credentials, access the supabase interface by navigating to http://localhost:8000. You are now ready to
continue on with the steps for supabase.com, you do not need to create a project as you are given an initialized one.
Skip the portion on copying environment variables, as you have already done this.

### Supabase.com Setup:
Create an account on supabase.com by clicking [here](https://supabase.com/dashboard/sign-up).

Once you have an account setup, you will first be brought to a page to create a organization.
Pick a name and continue. Next you will select the option to create a new project. 
Give the project some name, the value you set for the password is unimportant for the demo. 
Once the project is set up, click on the third icon on the sidebar; it should look like a terminal prompt.

Within the root of our project, there are 2 SQL files you will need to execute. One is for the tables 
themselves and an initial employee if you would like to log in and view the app as a brand-new instance. 
However, because most of our project is about displaying data, we also include some seed data for you to insert. 

Go ahead and copy and paste the contents the `schema.sql` file and hit run. To load in the seed data, follow the same 
steps; copy and paste the contents of `seed.sql` into the terminal and hit run. 
The database should now be established with all required data for the demonstration.

Lastly to give our project access to your newly created database, there are 3 environment variables you need to add. 
Check back on the left sidebar where you clicked earlier and find the settings icon at the bottom of the bar. 
This will show you another panel on the left of your screen, click on the label API.

Here you will find the 3 environment variables you will be replacing in the root file `.env`:

`NEXT_PUBLIC_SUPABASE_URL`: Project URL -> URL

`NEXT_PUBLIC_SUPABASE_ANON_KEY`: Project API keys -> (anon) (public)

`SUPABASE_SERVICE_KEY`: Project API keys -> (service_role) (secret)

With those copied, your project is now connected to your new database. You should be now be ready to deploy locally.

### Building and Running

To build and start our project, simply run:
```shell
npm run build_start
```
This will build the project and immediately start 
the Next.js server on `localhost:3000`. 

Connect to the website in your browser and use a pair of credentials in the next section to gain access

## Testing
To run the test suite for the program, run the following in the terminal:
```shell
npm run test
```
This will run all tests in `/src/tests`, reporting on the status of each test as it runs.

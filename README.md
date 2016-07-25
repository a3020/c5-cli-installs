# Concrete5 CLI Install Scripts

1. Edit database credentials in _config/latest.cfg
2. Run script: `./install.sh`

You can add a custom configuration file as parameter.
Create a .cfg file in _config and run the script like this:
`./install.sh name_file`

Important:
- If a directory already exists, it will be removed!
- If a database already exists, it will be dropped!
# Make sure to change your database info and what instance of DB you are using (i.e. sqlite3, mysql, postgres etc...)
# This script will rotate for a total of 5 logs so you can compare previous errors with current one without taking unnecessary space

# There's no strict requirement to place it in the root directory of the server, but you have some options for where to put it:

# Root Directory: Placing the script in the root directory could work, but it's generally not recommended to clutter the root directory
# with scripts. It's better to create a specific directory for your application and put the script there.

# Custom Directory: Create a specific directory for your application, and place the script there. 
# For example, you could create a directory called "my_app" or "database_error_logger" and place the script in that directory.

# Scripts Directory: Some servers have a designated directory for executable scripts. 
# You might check if your server has a "scripts" directory where you can place your script.

# Regardless of the location, it's essential to consider file permissions. 
# Ensure that the script has the necessary permissions to execute. You may need to use the chmod command to set the appropriate 
# permissions, depending on your server's configuration.

# Lastly, consider setting up a virtual environment for your Python script to isolate dependencies and avoid conflicts with other 
# applications on the server. This can help ensure that the required Python libraries are installed locally for your script
# without interfering with system-wide packages.    

# This script was created by Edward Freeman and is covered under GPL V3. You can modify this script as you need
# However, you must retain this GPL V3 standard, and leave credit where credit is due to the original author.

import logging
from logging.handlers import RotatingFileHandler
import sqlite3 #Make sure you change this to the correct Database provider (sqlite3, mysql, postgres etc..)
import sys

# Configure logging with rotating file handler
log_file = 'database_errors.log'
log_handler = RotatingFileHandler(log_file, maxBytes=1024 * 1024, backupCount=5)
log_formatter = logging.Formatter('%(asctime)s - %(levelname)s: %(message)s')
log_handler.setFormatter(log_formatter)
logger = logging.getLogger('DatabaseErrorLogger')
logger.setLevel(logging.ERROR)
logger.addHandler(log_handler)

def perform_database_operation():
    try:
        # Replace the following line with your actual database connection and query
        connection = sqlite3.connect('your_database.db')
        cursor = connection.cursor()

        # Replace the following line with your actual database operation
        cursor.execute('SELECT * FROM your_table;')

        # Don't forget to commit the changes if you are performing write operations
        connection.commit()

        connection.close()
    except Exception as e:
        # Log the error with the traceback using the logger
        logger.exception("Error occurred while performing the database operation.")
        raise  # Raising the error again allows the script to terminate or handle it at a higher level if needed

def custom_exception_handler(exctype, value, traceback):
    # Log uncaught exceptions using the logger
    logger.exception("Uncaught exception occurred.", exc_info=(exctype, value, traceback))

# Set the custom exception handler for uncaught exceptions
sys.excepthook = custom_exception_handler

# Call the function to perform the database operation
try:
    perform_database_operation()
except Exception as e:
    print("Error occurred during the database operation:", str(e))

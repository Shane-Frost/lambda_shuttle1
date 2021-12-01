# index.py

# Declaring the Python Function lambda_handler with event paramater
# This function uses event data that will be passed to the Lambda 
# function at runtime. It will then parse the first_name and last_name and return a message response.

#might not needs this. from a tutorial.

def lambda_handler(event, context):
    message = 'WHO IS YOUR PET AND WHAT DO THEY LIKE? {} eats {}!!!!'.format(event['pet_name'], event['fav_food'])  
    print(message)

    return { 
            'message' : message
    }
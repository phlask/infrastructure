import json

import boto3
import firebase_admin
from firebase_admin import db

FIREBASE_DB_URL = "https://phlask-usertest.firebaseio.com"

BASELINE_DATA_WATER = {
    "0": {
        "version": 1,
        "date_created": "2024-01-01T12:00:00:00Z",
        "creator": "phlask",
        "last_modified": "2024-01-01T12:00:00:00Z",
        "last_modifier": "phlask",
        "source": {
            "type": "MANUAL"
        },
        "verification": {
            "last_modified": "2024-01-01T12:00:00:00Z",
            "last_modifier": "phlask",
            "verified": True
        },
        "resource_type": "WATER",
        "address": "1500 Market Street, Suite 465",
        "city": "Philadelphia",
        "state": "PA",
        "zip_code": "19102",
        "latitude": 39.9525547665627,
        "longitude": -75.1667276472402,
        "gp_id": "EjUxNTAwIE1hcmtldCBTdCBzdWl0ZSA0NjUsIFBoaWxhZGVscGhpYSwgUEEgMTkxMDIsIFVTQSIlGiMKFgoUChIJxQZZFCnGxokRJ5loTwsfB6USCXN1aXRlIDQ2NQ",
        "guidelines": "Ask an available barista for water",
        "description": "Starbucks is required to hand out water to individuals who request, customer or not",
        "name": "Centre Square Starbucks",
        "status": "OPERATIONAL",
        "entry_type": "OPEN",
        "water": {
            "dispenser_type": [
                "SINK"
            ],
            "tags": [
                "WHEELCHAIR_ACCESSIBLE",
                "FILTERED",
                "BYOB"
            ]
        },
    },
    "1": {
        "version": 1,
        "date_created": "2024-01-01T12:00:00:00Z",
        "creator": "phlask",
        "last_modified": "2024-01-01T12:00:00:00Z",
        "last_modifier": "phlask",
        "source": {
            "type": "MANUAL"
        },
        "verification": {
            "last_modified": "2024-01-01T12:00:00:00Z",
            "last_modifier": "phlask",
            "verified": True
        },
        "resource_type": "WATER",
        "address": "1315 Spruce Street",
        "city": "Philadelphia",
        "state": "PA",
        "zip_code": "19107",
        "latitude": 39.9469811652149,
        "longitude": -75.1633515946442,
        "gp_id": "ChIJbdJ1ByXGxokRMSnp3Q7fRiQ",
        "guidelines": "",
        "description": "The bottle filler and fountain is located just to the right of the welcome desk in the lobby.",
        "name": "William Way LGBT Community Center",
        "status": "OPERATIONAL",
        "entry_type": "OPEN",
        "water": {
            "url": "https://www.waygay.org/",
            "dispenser_type": [
                "BOTTLE_FILLER"
            ],
            "tags": [
                "WHEELCHAIR_ACCESSIBLE",
                "FILTERED"
            ]
        },
    },
    "2": {
        "version": 1,
        "date_created": "2024-01-01T12:00:00:00Z",
        "creator": "phlask",
        "last_modified": "2024-01-01T12:00:00:00Z",
        "last_modifier": "phlask",
        "source": {
            "type": "MANUAL"
        },
        "verification": {
            "last_modified": "2024-01-01T12:00:00:00Z",
            "last_modifier": "phlask",
            "verified": True
        },
        "resource_type": "WATER",
        "address": "Market Street between 10th and 12th Streets",
        "city": "Philadelphia",
        "state": "PA",
        "zip_code": "19107",
        "latitude": 39.9525766365353,
        "longitude": -75.1580551702174,
        "gp_id": "ChIJ17nt_tDHxokRO8TqYWM69qQ",
        "guidelines": "Drinking fountain available during operating hours",
        "description": "Drinking fountain near SEPTA ticket window at 10th st. entrance",
        "name": "Jefferson Station",
        "status": "OPERATIONAL",
        "entry_type": "OPEN",
        "water": {
            "url": "http://www.septa.org/stations/rail/jefferson.html",
            "dispenser_type": [
                "DRINKING_FOUNTAIN"
            ],
            "tags": [
                "WHEELCHAIR_ACCESSIBLE"
            ]
        },
    },
    "3": {
        "version": 1,
        "date_created": "2024-01-01T12:00:00:00Z",
        "creator": "phlask",
        "last_modified": "2024-01-01T12:00:00:00Z",
        "last_modifier": "phlask",
        "source": {
            "type": "MANUAL"
        },
        "verification": {
            "last_modified": "2024-01-01T12:00:00:00Z",
            "last_modifier": "phlask",
            "verified": True
        },
        "resource_type": "WATER",
        "address": "1414 South Penn Square",
        "city": "Philadelphia",
        "state": "PA",
        "zip_code": "19102",
        "latitude": 39.9515807983695,
        "longitude": -75.1650486177946,
        "gp_id": "ChIJdx8ftC_GxokR5N-R3NsEvp0",
        "guidelines": "Bring a bottle if you don't want to use a single use plastic one!!",
        "description": "On the coffee bar are taps for still and carbonated water",
        "name": "La Colombe @ South Penn Square",
        "status": "OPERATIONAL",
        "entry_type": "OPEN",
        "water": {
            "url": "http://www.lacolombe.com/",
            "dispenser_type": [
                "DRINKING_FOUNTAIN"
            ],
            "tags": [
                "WHEELCHAIR_ACCESSIBLE",
                "FILTERED",
                "BYOB"
            ]
        },
    },
    "4": {
        "version": 1,
        "date_created": "2024-01-01T12:00:00:00Z",
        "creator": "phlask",
        "last_modified": "2024-01-01T12:00:00:00Z",
        "last_modifier": "phlask",
        "source": {
            "type": "MANUAL"
        },
        "verification": {
            "last_modified": "2024-01-01T12:00:00:00Z",
            "last_modifier": "phlask",
            "verified": True
        },
        "resource_type": "WATER",
        "address": "1800 Walnut St",
        "city": "Philadelphia",
        "state": "PA",
        "zip_code": "19103",
        "latitude": 39.9495032242089,
        "longitude": -75.1719049110455,
        "gp_id": "ChIJzVOaqDvGxokRPPzp8p_wIZo",
        "guidelines": "Public park, please don't leave trash",
        "description": "Park drinking fountain in the summer",
        "name": "Rittenhouse Square",
        "status": "OPERATIONAL",
        "entry_type": "OPEN",
        "water": {
            "dispenser_type": [
                "DRINKING_FOUNTAIN"
            ],
            "tags": []
        },
    },
    "5": {
        "version": 1,
        "date_created": "2024-01-01T12:00:00:00Z",
        "creator": "phlask",
        "last_modified": "2024-01-01T12:00:00:00Z",
        "last_modifier": "phlask",
        "source": {
            "type": "MANUAL"
        },
        "verification": {
            "last_modified": "2024-01-01T12:00:00:00Z",
            "last_modifier": "phlask",
            "verified": True
        },
        "resource_type": "WATER",
        "address": "1901 Vine St",
        "city": "Philadelphia",
        "state": "PA",
        "zip_code": "19103",
        "latitude": 39.9603706109909,
        "longitude": -75.1711088730158,
        "gp_id": "ChIJ_x-wODPGxokREDE-Lq4X9dE",
        "guidelines": "Shhh it's a library",
        "description": "Drinking fountain on 1st floor, outside of Government Publications room",
        "name": "Parkway Central Library",
        "status": "OPERATIONAL",
        "entry_type": "OPEN",
        "water": {
            "dispenser_type": [
                "DRINKING_FOUNTAIN"
            ],
            "tags": [
                "FILTERED",
                "BYOB"
            ]
        },
    }
}

BASELINE_DATA_FOOD = {
    "0": {
        "version": 1,
        "date_created": "2024-01-01T12:00:00:00Z",
        "creator": "phlask",
        "last_modified": "2024-01-01T12:00:00:00Z",
        "last_modifier": "phlask",
        "source": {
            "type": "MANUAL"
        },
        "verification": {
            "last_modified": "2024-01-01T12:00:00:00Z",
            "last_modifier": "phlask",
            "verified": True
        },
        "resource_type": "FOOD",
        "address": "1400 John F Kennedy Blvd",
        "city": "Philadelphia",
        "state": "PA",
        "zip_code": "19107",
        "latitude": 39.9533428111162,
        "longitude": -75.1633974693126,
        "gp_id": "ChIJyb-70KChxokR5YR1l-Nka5s",
        "guidelines": "Only take 1 bag because they run out fast here",
        "description": "Every tuesday and thursday there is a food giveaway at city hall. They tend to run out quickly so get there fast.",
        "name": "City Hall Food Giveaway",
        "status": "OPERATIONAL",
        "entry_type": "",
        "food": {
            "food_type": [
                "NON_PERISHABLE"
            ],
            "distribution_type": [
                "PICKUP"
            ],
            "organization_type": [
                "GOVERNMENT"
            ],
            "organization_name": "",
            "organization_url": "",
            "tags": [
                "WHEELCHAIR_ACCESSIBLE"
            ]
        }
    },
    "1": {
        "version": 1,
        "date_created": "2024-01-01T12:00:00:00Z",
        "creator": "phlask",
        "last_modified": "2024-01-01T12:00:00:00Z",
        "last_modifier": "phlask",
        "source": {
            "type": "MANUAL"
        },
        "verification": {
            "last_modified": "2024-01-01T12:00:00:00Z",
            "last_modifier": "phlask",
            "verified": True
        },
        "resource_type": "FOOD",
        "address": "5100 Pine St",
        "city": "Philadelphia",
        "state": "PA",
        "zip_code": "19143",
        "latitude": 39.9530268807341,
        "longitude": -75.2255815696713,
        "gp_id": "ChIJxyUiG8LGxokR-B64pUFtwuE",
        "guidelines": "You can grab multiple bags but only 1 at a time",
        "description": "Every two weeks Sharing Excess provides food here from 12-2",
        "name": "Sharing Excess Food Bank",
        "status": "OPERATIONAL",
        "entry_type": "",
        "food": {
            "food_type": [
                "PERISHABLE"
            ],
            "distribution_type": [
                "PICKUP"
            ],
            "organization_type": [
                "NON_PROFIT"
            ],
            "organization_name": "Sharing Excess",
            "organization_url": "https://www.sharingexcess.com/",
            "tags": [
                "WHEELCHAIR_ACCESSIBLE",
                "ID_REQUIRED"
            ]
        }
    },
    "2": {
        "version": 1,
        "date_created": "2024-01-01T12:00:00:00Z",
        "creator": "phlask",
        "last_modified": "2024-01-01T12:00:00:00Z",
        "last_modifier": "phlask",
        "source": {
            "type": "MANUAL"
        },
        "verification": {
            "last_modified": "2024-01-01T12:00:00:00Z",
            "last_modifier": "phlask",
            "verified": True
        },
        "resource_type": "FOOD",
        "address": "2110 Chestnut St",
        "city": "Philadelphia",
        "state": "PA",
        "zip_code": "19103",
        "latitude": 39.9522910516263,
        "longitude": -75.1759675202545,
        "gp_id": "Ei0yMTEwIENoZXN0bnV0IFN0LCBQaGlsYWRlbHBoaWEsIFBBIDE5MTAzLCBVU0EiMRIvChQKEgldd568N8bGiREU1vePjIo5mhC-ECoUChIJr2s0IvjGxokR4h5gTUf_rIA",
        "guidelines": "1 meal per person",
        "description": "Every Friday come get a warm meal",
        "name": "Lutheran Church Of Holy Communion-Food Cabinet",
        "status": "OPERATIONAL",
        "entry_type": "",
        "food": {
            "food_type": [
                "PERISHABLE"
            ],
            "distribution_type": [
                "EAT_ON_SITE"
            ],
            "organization_type": [
                "NON_PROFIT"
            ],
            "organization_name": "Lutheran Church Of Holy Communion",
            "organization_url": "https://www.lc-hc.org/content.cfm?id=102",
            "tags": [
                "WHEELCHAIR_ACCESSIBLE",
                "ID_REQUIRED"
            ]
        }
    },
    "3": {
        "version": 1,
        "date_created": "2024-01-01T12:00:00:00Z",
        "creator": "phlask",
        "last_modified": "2024-01-01T12:00:00:00Z",
        "last_modifier": "phlask",
        "source": {
            "type": "MANUAL"
        },
        "verification": {
            "last_modified": "2024-01-01T12:00:00:00Z",
            "last_modifier": "phlask",
            "verified": True
        },
        "resource_type": "FOOD",
        "address": "1235 Spring Garden St",
        "city": "Philadelphia",
        "state": "PA",
        "zip_code": "19123",
        "latitude": 39.9629945924768,
        "longitude": -75.1585804406548,
        "gp_id": "ChIJxUsiQdTHxokRunUeFlTiHis",
        "guidelines": "Uses a point system",
        "description": "Non perishables only",
        "name": "Bebashi - Food Pantry",
        "status": "OPERATIONAL",
        "entry_type": "",
        "food": {
            "food_type": [
                "NON_PERISHABLE"
            ],
            "distribution_type": [
                "PICKUP"
            ],
            "organization_type": [
                "BUSINESS"
            ],
            "organization_name": "Bebashi",
            "organization_url": "",
            "tags": [
                "ID_REQUIRED"
            ]
        }
    }
}

BASELINE_DATA_FORAGING = {
    "0": {
        "version": 1,
        "date_created": "2024-01-01T12:00:00:00Z",
        "creator": "phlask",
        "last_modified": "2024-01-01T12:00:00:00Z",
        "last_modifier": "phlask",
        "source": {
            "type": "MANUAL"
        },
        "verification": {
            "last_modified": "2024-01-01T12:00:00:00Z",
            "last_modifier": "phlask",
            "verified": True
        },
        "resource_type": "FORAGE",
        "address": "",
        "city": "Philadelphia",
        "state": "PA",
        "zip_code": "19103",
        "latitude": 39.955422,
        "longitude": -75.167933,
        "gp_id": "EioxMDEgTiAxN3RoIFN0LCBQaGlsYWRlbHBoaWEsIFBBIDE5MTAzLCBVU0EiMBIuChQKEgl_l9w8MsbGiRFcLu8WrA6rNRBlKhQKEgk_0BpY48fGiRFoMqaQZkhYkw",
        "guidelines": "Drops helpful leaves around the base",
        "description": "Ginkgo Tree",
        "name": "Ginkgo Tree",
        "status": "OPERATIONAL",
        "entry_type": "OPEN",
        "forage": {
            "organization_url": "",
            "forage_type": [
                "BARK",
                "LEAVES"
            ],
            "tags": [
                "IN_SEASON"
            ]
        }
    },
    "1": {
        "version": 1,
        "date_created": "2024-01-01T12:00:00:00Z",
        "creator": "phlask",
        "last_modified": "2024-01-01T12:00:00:00Z",
        "last_modifier": "phlask",
        "source": {
            "type": "MANUAL"
        },
        "verification": {
            "last_modified": "2024-01-01T12:00:00:00Z",
            "last_modifier": "phlask",
            "verified": True
        },
        "resource_type": "FORAGE",
        "address": "2-6 North Juniper Street",
        "city": "Philadelphia",
        "state": "PA",
        "zip_code": "19107",
        "latitude": 39.952538,
        "longitude": -75.162682,
        "gp_id": "EisyIE4gSnVuaXBlciBTdCwgUGhpbGFkZWxwaGlhLCBQQSAxOTEwNywgVVNBIjASLgoUChIJcQEt8C7GxokR72h1Vk_81mgQAioUChIJ50yuPSzGxokR-r7h55FRIZ8",
        "guidelines": "Only take what you need please this is a rare tree",
        "description": "This is a Apple serviceberry under the genus 'Amelanchier' and species 'x grandiflora'. The planting site ID is 361022, and the tree ID is 328224.",
        "name": "Apple serviceberry",
        "status": "OPERATIONAL",
        "entry_type": "OPEN",
        "forage": {
            "organization_url": "",
            "forage_type": [
                "BARK",
                "LEAVES"
            ],
            "tags": [
                "IN_SEASON"
            ]
        }
    },
    "2": {
        "version": 1,
        "date_created": "2024-01-01T12:00:00:00Z",
        "creator": "phlask",
        "last_modified": "2024-01-01T12:00:00:00Z",
        "last_modifier": "phlask",
        "source": {
            "type": "MANUAL"
        },
        "verification": {
            "last_modified": "2024-01-01T12:00:00:00Z",
            "last_modifier": "phlask",
            "verified": True
        },
        "resource_type": "FORAGE",
        "address": "1114-1118 Locust St",
        "city": "Philadelphia",
        "state": "PA",
        "zip_code": "19107",
        "latitude": 39.9480717578204,
        "longitude": -75.1602569509981,
        "gp_id": "ChIJ9eK3CibGxokRRx6Tc9D6iG0",
        "guidelines": "Please sign up to be a member on the website to get a key",
        "description": "Open to members community gardens",
        "name": "Sartain Street Community Garden",
        "status": "OPERATIONAL",
        "entry_type": "OPEN",
        "forage": {
            "organization_url": "http://www.washwestcivic.org/community-gardens",
            "forage_type": [
                "FRUIT",
                "FLOWERS"
            ],
            "tags": [
                "COMMUNITY_GARDEN"
            ]
        }
    }
}

BASELINE_DATA_BATHROOM = {
    "0": {
        "version": 1,
        "date_created": "2024-01-01T12:00:00:00Z",
        "creator": "phlask",
        "last_modified": "2024-01-01T12:00:00:00Z",
        "last_modifier": "phlask",
        "source": {
            "type": "MANUAL"
        },
        "verification": {
            "last_modified": "2024-01-01T12:00:00:00Z",
            "last_modifier": "phlask",
            "verified": True
        },
        "resource_type": "BATHROOM",
        "address": "1136 Arch St, Philadelphia",
        "city": "Philadelphia",
        "state": "PA",
        "zip_code": "19107",
        "latitude": 39.9544147890993,
        "longitude": -75.1582787809528,
        "gp_id": "ChIJCQH7WCnGxokRAWsd3AfQj80",
        "guidelines": "",
        "description": "The restrooms (including a family restroom) are at the back of the building in the northwest corner — nearest access is the tucked-away back entrance on Arch between 11th and 12th — between the Pennsylvania General Store and the security/housekeeping station. Just follow the small but helpful green signs.",
        "name": "Reading Terminal Market",
        "status": "OPERATIONAL",
        "entry_type": "OPEN",
        "bathroom": {
            "tags": [
                "WHEELCHAIR_ACCESSIBLE",
                "CHANGING_TABLE"
            ]
        }
    },
    "1": {
        "version": 1,
        "date_created": "2024-01-01T12:00:00:00Z",
        "creator": "phlask",
        "last_modified": "2024-01-01T12:00:00:00Z",
        "last_modifier": "phlask",
        "source": {
            "type": "MANUAL"
        },
        "verification": {
            "last_modified": "2024-01-01T12:00:00:00Z",
            "last_modifier": "phlask",
            "verified": True
        },
        "resource_type": "BATHROOM",
        "address": "901 Market St",
        "city": "Philadelphia",
        "state": "PA",
        "zip_code": "19107",
        "latitude": 39.9521809329656,
        "longitude": -75.1558257288357,
        "gp_id": "ChIJp5Tr2inGxokR_f5EOjiTbnI",
        "guidelines": "",
        "description": "There are lots of restrooms at this location: - Two restrooms at street level (near the Filbert Street entrance by Kate Spade, and by Burlington Coat Factory at the 9th Street entrance) - Two restrooms on the concourse level (by T-Mobile and City Winery) - Two restrooms on the second level (by Wonderspaces and behind Levi’s Outlet) - Family restrooms are located on the concourse and second levels, and five specific wheelchair-accessible restrooms are also available",
        "name": "Fashion District Philadelphia (Mall)",
        "status": "OPERATIONAL",
        "entry_type": "OPEN",
        "bathroom": {
            "tags": [
                "WHEELCHAIR_ACCESSIBLE"
            ]
        }
    }
}

def generate_default_test_data():
    index = 0
    full_data = {}
    for _, tap in BASELINE_DATA_WATER.items():
        full_data[index] = tap
        index = index + 1
    for _, tap in BASELINE_DATA_FOOD.items():
        full_data[index] = tap
        index = index + 1
    for _, tap in BASELINE_DATA_FORAGING.items():
        full_data[index] = tap
        index = index + 1
    for _, tap in BASELINE_DATA_BATHROOM.items():
        full_data[index] = tap
        index = index + 1
    
    return full_data

def lambda_handler(event, context):
    # response = event['Records'][0]['cf']['response']
    response = {
        'statusDescription': 'OK'
    }
    # request = event['Records'][0]['cf']['request'] This function does not use the request

    try:
        # Get Firebase credentials from Parameter Store
        ssm = boto3.client('ssm', region_name="us-east-1")
        firebase_credentials = json.loads(ssm.get_parameter(
            Name='/firebase/sdk-credentials',
            WithDecryption=True
        )['Parameter']['Value'])

        # Get a database reference.
        cred = firebase_admin.credentials.Certificate({
            "type": "service_account",
            "project_id": firebase_credentials["project_id"],
            "private_key_id": firebase_credentials["private_key_id"],
            "private_key": firebase_credentials["private_key"],
            "client_email": firebase_credentials["client_email"],
            "client_id": firebase_credentials["client_id"],
            "auth_uri": "https://accounts.google.com/o/oauth2/auth",
            "token_uri": "https://oauth2.googleapis.com/token",
            "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
            "client_x509_cert_url": firebase_credentials["client_x509_cert_url"]
        })

        firebase_app = firebase_admin.initialize_app(
            cred,
            options={
                'databaseURL': FIREBASE_DB_URL
            }
        )
        
        # Reference to root of database
        ref = db.reference('/')

        # Sample dataset with a few test taps
        test_data = generate_default_test_data()

        # Set data at reference, overwriting existing data
        ref.set(test_data)

        # Clean up Firebase app
        firebase_admin.delete_app(firebase_app)
        response['body'] = "Successfully reset UserTest DB, happy testing! :)"

    except Exception as e:
        print(f"Error resetting database: {str(e)}")
        import traceback
        print(traceback.format_exc())
        response['body'] = "Failed to reset DB! Try again or contact #phlask_dev for support"
        
    response['status'] = 200
    return response

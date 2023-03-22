import os
import secrets

from dotenv import load_dotenv

load_dotenv(dotenv_path='.env')

conf_file = os.getenv("CONFIG_FILE", 'config.json')
kafka_message_size = int(os.getenv('KAFKA_MESSAGE_SIZE', 10))
secret_password = os.getenv("SECRET_PASSWORD", secrets.token_hex())
namespace_mappings = {"bigg": "bigg", "wgs": "wgs"}
ts_buckets = int(os.getenv('TS_BUCKETS', 10000000))
buckets = int(os.getenv('BUCKETS', 20))
sources_priorities = ["Org", "Greece", "Czech"]
countries = ["GR", 'CZ']

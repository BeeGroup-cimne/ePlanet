from utils.nomenclature import raw_nomenclature, RawMode

from sources import SourcePlugin
from sources.Greece.gather import gather
from sources.Greece.harmonizer.mapping_data import harmonize_data


class Plugin(SourcePlugin):
    source_name = "Greece"

    def gather(self, arguments):
        gather(arguments, settings=self.settings, config=self.config)

    def get_mapper(self, message):
        if message["collection_type"] == 'BuildingInfo':
            return harmonize_data

    def get_kwargs(self, message):
        return {
            "namespace": message['namespace'],
            "user": message['user'],
            "config": self.config
        }

    def get_store_table(self, message):
        return raw_nomenclature(source=self.source_name, mode=RawMode.STATIC, data_type=message["collection_type"],
                                frequency="", user=message['user'])

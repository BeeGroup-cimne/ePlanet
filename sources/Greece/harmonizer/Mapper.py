from utils.data_transformations import to_object_property

from ontology.bigg_classes import Building, LocationInfo, BuildingSpace, Device, UtilityPointOfDelivery, \
    Organization
from ontology.namespaces_definition import countries, bigg_enums, Bigg


class Mapper(object):
    def __init__(self, source, namespace):
        self.source = source
        Building.set_namespace(namespace)
        LocationInfo.set_namespace(namespace)
        BuildingSpace.set_namespace(namespace)
        Device.set_namespace(namespace)
        UtilityPointOfDelivery.set_namespace(namespace)
        Organization.set_namespace(namespace)

    def get_mappings(self, group):

        main_organization = {
            "name": "organization",
            "class": Organization,
            "type": {
                "origin": "static"
            },
            "params": {
                "raw": {
                    "subject": "greece",
                    "organizationName": "Greece"
                }
            },
            "links": {
                "location_organization": {
                    "type": Bigg.hasSubOrganization,
                    "link": "__all__"
                }
            }
        }

        location_organization = {
            "name": "location_organization",
            "class": Organization,
            "type": {
                "origin": "row"
            },
            "params": {
                "raw": {
                    "organizationDivisionType": "Location"
                },
                "mapping": {
                    "subject": {
                        "key": "location_organization_subject",
                        "operations": []
                    },
                    "organizationName": {
                        "key": "Municipality",
                        "operations": []
                    }
                }
            },
            "links": {
                "building_organization": {
                    "type": Bigg.hasSubOrganization,
                    "link": "building_organization_subject"
                }
            }
        }

        building_organization = {
            "name": "building_organization",
            "class": Organization,
            "type": {
                "origin": "row"
            },
            "params": {
                "raw": {
                    "organizationDivisionType": "Building"
                },
                "mapping": {
                    "subject": {
                        "key": "building_organization_subject",
                        "operations": []
                    },
                    "organizationName": {
                        "key": "Name of the building or public lighting",
                        "operations": []
                    }
                }
            },
            "links": {
                "buildings": {
                    "type": Bigg.managesBuilding,
                    "link": "building_subject"
                }
            }
        }
        buildings = {
            "name": "buildings",
            "class": Building,
            "type": {
                "origin": "row"
            },
            "params": {
                "raw": {
                },
                "mapping": {
                    "subject": {
                        "key": "building_subject",
                        "operations": []
                    },
                    "buildingName": {
                        "key": "Name of the building or public lighting",
                        "operations": []
                    },
                    "buildingIDFromOrganization": {
                        "key": "Unique ID",
                        "operations": []
                    }
                }
            },
            "links": {
                "building_space": {
                    "type": Bigg.hasSpace,
                    "link": "building_subject"
                },
                "locations": {
                    "type": Bigg.hasLocationInfo,
                    "link": "building_subject"
                }
            }
        }

        building_space = {
            "name": "building_space",
            "class": BuildingSpace,
            "type": {
                "origin": "row"
            },
            "params": {
                "raw": {
                    "buildingSpaceName": "Building"
                },
                "mapping": {
                    "subject": {
                        "key": "building_space_subject",
                        "operations": []
                    }
                }
            },
            "links": {
                "device": {
                    "type": Bigg.isObservedByDevice,
                    "link": "building_subject"
                }
            }
        }

        locations = {
            "name": "locations",
            "class": LocationInfo,
            "type": {
                "origin": "row"
            },
            "params": {
                "raw": {
                    "hasAddressCountry": countries["390903/"]
                },
                "mapping": {
                    "subject": {
                        "key": "location_subject",
                        "operations": []
                    },
                    "addressStreetName": {
                        "key": "Street",
                        "operations": []
                    },
                    "addressStreetNumber": {
                        "key": "Street num",
                        "operations": []
                    },
                    "hasAddressCity": {
                        "key": "hasAddressCity",
                        "operations": []
                    },
                    "hasAddressProvince": {
                        "key": "hasAddressProvince",
                        "operations": []
                    }
                }
            }
        }

        device = {
            "name": "device",
            "class": Device,
            "type": {
                "origin": "row"
            },
            "params": {
                "raw": {
                    "hasDeviceType": to_object_property("Meter.EnergyMeter", namespace=bigg_enums)
                },
                "mapping": {
                    "subject": {
                        "key": "device_subject",
                        "operations": []
                    },
                    "deviceName": {
                        "key": 'Unique ID',
                        "operations": []
                    }
                }
            }
        }

        grouped_modules = {
            "static": [main_organization, location_organization, building_organization, buildings,
                       locations, building_space, device]
        }
        return grouped_modules[group]

from ontology.bigg_classes import Building, LocationInfo, BuildingSpace, Area, \
    EnergyPerformanceCertificate, AreaType, AreaUnitOfMeasurement, BuildingOwnership, Device, \
    Element, EnergyEfficiencyMeasure, EnergySaving, Project, EnergyPerformanceCertificateAdditionalInfo, Organization
from ontology.namespaces_definition import units, countries, bigg_enums, Bigg


class Mapper(object):
    def __init__(self, source, namespace):
        self.source = source
        Building.set_namespace(namespace)
        BuildingOwnership.set_namespace(namespace)
        LocationInfo.set_namespace(namespace)
        BuildingSpace.set_namespace(namespace)
        Area.set_namespace(namespace)
        EnergyPerformanceCertificate.set_namespace(namespace)
        AreaType.set_namespace(namespace)
        AreaUnitOfMeasurement.set_namespace(namespace)
        Project.set_namespace(namespace)
        Element.set_namespace(namespace)
        Device.set_namespace(namespace)
        EnergyEfficiencyMeasure.set_namespace(namespace)
        EnergyPerformanceCertificateAdditionalInfo.set_namespace(namespace)
        EnergySaving.set_namespace(namespace)
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
                    "subject": "czech",
                    "organizationName": "Czech"
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
                        "key": "organization",
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
                        "key": "building_name",
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
                "mapping": {
                    "subject": {
                        "key": "building_subject",
                        "operations": []
                    },
                    "buildingName": {
                        "key": "Name",
                        "operations": []
                    },
                    "buildingIDFromOrganization": {
                        "key": "Unique ID",
                        "operations": []
                    },
                    "buildingConstructionYear": {
                        "key": "YearOfConstruction",
                        "operations": []
                    },
                }
            },
            "links": {
                "building_space": {
                    "type": Bigg.hasSpace,
                    "link": "building_subject"
                },
                "location_info": {
                    "type": Bigg.hasLocationInfo,
                    "link": "building_subject"
                },
                "energy_performance_certificate": {
                    "type": Bigg.hasEPC,
                    "link": "building_subject"
                },
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
                    },
                    "hasBuildingSpaceUseType": {
                        "key": "buildingSpaceUseType",
                        "operations": []
                    }
                }
            },
            "links": {
                "gross_floor_area": {
                    "type": Bigg.hasArea,
                    "link": "building_subject"
                },
                "element": {
                    "type": Bigg.isAssociatedWithElement,
                    "link": "building_subject"
                },
                "device": {
                    "type": Bigg.isObservedByDevice,
                    "link": "building_subject"
                },
            }
        }

        location_info = {
            "name": "location_info",
            "class": LocationInfo,
            "type": {
                "origin": "row"
            },
            "params": {
                "raw": {
                    "hasAddressCountry": countries["3077311/"]
                },
                "mapping": {
                    "subject": {
                        "key": "location_subject",
                        "operations": []
                    },
                    "hasAddressProvince": {
                        "key": "hasAddressProvince",
                        "operations": []
                    },
                    "addressLatitude": {
                        "key": "Latitude",
                        "operations": []
                    },
                    "addressLongitude": {
                        "key": "Longitude",
                        "operations": []
                    },
                    "addressStreetName": {
                        "key": "Road",
                        "operations": []
                    },
                    "addressStreetNumber": {
                        "key": "Road Number",
                        "operations": []
                    },
                    "addressPostalCode": {
                        "key": "PostalCode",
                        "operations": []
                    },
                    "hasAddressCity": {
                        "key": "hasAddressCity",
                        "operations": []
                    },

                }
            }
        }

        gross_floor_area = {
            "name": "gross_floor_area",
            "class": Area,
            "type": {
                "origin": "row"
            },
            "params": {
                "raw": {
                    "hasAreaType": bigg_enums["GrossFloorAreaAboveGround"],
                    "hasAreaUnitOfMeasurement": units["M2"]
                },
                "mapping": {
                    "subject": {
                        "key": "gross_floor_area_subject",
                        "operations": []
                    },
                    "areaValue": {
                        "key": "GrossFloorArea",
                        "operations": []
                    }
                }
            }
        }

        energy_performance_certificate = {
            "name": "energy_performance_certificate",
            "class": EnergyPerformanceCertificate,
            "type": {
                "origin": "row"
            },
            "params": {
                "mapping": {
                    "subject": {
                        "key": "energy_performance_certificate_subject",
                        "operations": []
                    },
                    "energyPerformanceCertificateDateOfAssessment": {
                        "key": "EnergyCertificateDate",
                        "operations": []
                    },
                    "energyPerformanceCertificateClass": {
                        "key": "Klasifikační třída budovy dle PENB",
                        "operations": []
                    }
                }
            },
            "links": {
                "epc_add": {
                    "type": Bigg.hasAdditionalInfo,
                    "link": "building_subject"
                },
            }
        }

        epc_add = {
            "name": "epc_add",
            "class": EnergyPerformanceCertificateAdditionalInfo,
            "type": {
                "origin": "row"
            },
            "params": {
                "mapping": {
                    "subject": {
                        "key": "energy_performance_certificate_additional_subject",
                        "operations": []
                    },
                    "solarPVSystemPresence": {
                        "key": "SolarPV",
                        "operations": []
                    },
                    "solarThermalSystemPresence": {
                        "key": "SolarThermal",
                        "operations": []
                    }
                },
            }
        }

        element = {
            "name": "element",
            "class": Element,
            "type": {
                "origin": "row"
            },
            "params": {
                "mapping": {
                    "subject": {
                        "key": "element_subject",
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
                "mapping": {
                    "subject": {
                        "key": "device_subject",
                        "operations": []
                    },
                }
            }
        }

        eem_element = {
            "name": "element",
            "class": Element,
            "type": {
                "origin": "row"
            },
            "params": {
                "mapping": {
                    "subject": {
                        "key": "element_subject",
                        "operations": []
                    }
                }
            },
            "links": {
                "eem": {
                    "type": Bigg.isAffectedByMeasure,
                    "link": "energy_efficiency_measure_subject"
                }
            }
        }

        eem = {
            "name": "eem",
            "class": EnergyEfficiencyMeasure,
            "type": {
                "origin": "row"
            },
            "params": {
                "raw": {
                    "hasEnergyEfficiencyMeasureInvestmentCurrency": units["CzechKoruna"],
                },
                "mapping": {
                    "subject": {
                        "key": "energy_efficiency_measure_subject",
                        "operations": []
                    },
                    "energyEfficiencyMeasureCurrencyExchangeRate": {
                        "key": "Currency Rate",
                        "operations": []
                    },
                    "energyEfficiencyMeasureInvestment": {
                        "key": "Investment",
                        "operations": []
                    },
                    "hasEnergyEfficiencyMeasureType": {
                        "key": "hasEnergyEfficiencyMeasureType",
                        "operations": []
                    },
                    "label": {
                        "key": "ETM Name",
                        "operations": []
                    },
                    "energyEfficiencyMeasureCO2Reduction": {
                        "key": "Annual CO2 reduction",
                        "operations": []
                    }
                },
                "links": {
                    "energy_saving": {
                        "type": Bigg.producesSaving,
                        "link": "energy_efficiency_measure_subject"
                    }
                }
            }
        }

        energy_saving = {
            "name": "energy_saving",
            "class": EnergySaving,
            "type": {
                "origin": "row"
            },
            "params": {
                "mapping": {
                    "subject": {
                        "key": "energy_saving_subject",
                        "operations": []
                    }, "energySavingStartDate": {
                        "key": "energySavingStartDate",
                        "operations": []
                    }, "energySavingValue": {
                        "key": "Annual Energy Savings",
                        "operations": []
                    }, "hasEnergySavingType": {
                        "key": "hasEnergySavingType",
                        "operations": []
                    }
                },
            }
        }

        grouped_modules = {
            "building_info": [main_organization, location_organization, building_organization, buildings,
                              building_space, location_info, gross_floor_area, energy_performance_certificate, epc_add,
                              device, element],
            "emm": [eem_element, eem, energy_saving]
        }
        return grouped_modules[group]

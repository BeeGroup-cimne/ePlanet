import unittest

from dotenv import load_dotenv

from external_integration.Inergy.sources.InergySource import InergySource


class SourceTesting(unittest.TestCase):
    token = ""

    def setUp(self):
        load_dotenv()

    def test_1_get_credentials(self):
        InergySource.authenticate()
        self.assertIsNotNone(InergySource.token)
        self.__class__.token = InergySource.token

    def test_2_generate_element(self):
        InergySource.insert_elements(self.token)


if __name__ == '__main__':
    unittest.main()

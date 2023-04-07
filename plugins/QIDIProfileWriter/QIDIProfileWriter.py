# Copyright (c) 2015 QIDI B.V.
# Copyright (c) 2013 David Braam
# QDTECH is released under the terms of the LGPLv3 or higher.

from QD.Logger import Logger
from qidi.ReaderWriters.ProfileWriter import ProfileWriter
import zipfile

class QIDIProfileWriter(ProfileWriter):
    """Writes profiles to QIDI's own profile format with config files."""

    def write(self, path, profiles):
        """Writes a profile to the specified file path.

        :param path: :type{string} The file to output to.
        :param profiles: :type{Profile} :type{List} The profile(s) to write to that file.
        :return: True if the writing was successful, or
                 False if it wasn't.
        """

        if type(profiles) != list:
            profiles = [profiles]

        stream = open(path, "wb")  # Open file for writing in binary.
        archive = zipfile.ZipFile(stream, "w", compression=zipfile.ZIP_DEFLATED)
        try:
            # Open the specified file.
            for profile in profiles:
                serialized = profile.serialize()
                profile_file = zipfile.ZipInfo(profile.getId())
                archive.writestr(profile_file, serialized)
        except Exception as e:
            Logger.log("e", "Failed to write profile to %s: %s", path, str(e))
            return False
        finally:
            archive.close()
        return True

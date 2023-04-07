from typing import Union

from qidi import ApplicationMetadata
from qidi.QIDICloud import QIDICloudConstants


class CloudApiModel:
    sdk_version = ApplicationMetadata.QIDISDKVersion  # type: Union[str, int]
    cloud_api_version = QIDICloudConstants.QIDICloudAPIVersion  # type: str
    cloud_api_root = QIDICloudConstants.QIDICloudAPIRoot  # type: str
    api_url = "{cloud_api_root}/qidi-packages/v{cloud_api_version}/qidi/v{sdk_version}".format(
            cloud_api_root = cloud_api_root,
            cloud_api_version = cloud_api_version,
            sdk_version = sdk_version
        )  # type: str

 
    api_url_user_packages = "{cloud_api_root}/qidi-packages/v{cloud_api_version}/user/packages".format(
        cloud_api_root=cloud_api_root,
        cloud_api_version=cloud_api_version,
    )

    @classmethod
    def userPackageUrl(cls, package_id: str) -> str:

        return (CloudApiModel.api_url_user_packages + "/{package_id}").format(
            package_id=package_id
        )

from PyQt5.QtNetwork import QNetworkRequest

from QD.Logger import Logger
from QD.TaskManagement.HttpRequestScope import DefaultUserAgentScope
from qidi.API import Account
from qidi.QIDIApplication import QIDIApplication


class QIDICloudScope(DefaultUserAgentScope):


    def __init__(self, application: QIDIApplication):
        super().__init__(application)
        api = application.getQIDIAPI()
        self._account = api.account  # type: Account

    def requestHook(self, request: QNetworkRequest):
        super().requestHook(request)
        token = self._account.accessToken
        if not self._account.isLoggedIn or token is None:
            Logger.debug("User is not logged in for Cloud API request to {url}".format(url = request.url().toDisplayString()))
            return

        header_dict = {
            "Authorization": "Bearer {}".format(token)
        }
        self.addHeaders(request, header_dict)

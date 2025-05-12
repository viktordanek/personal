#!/usr/bin/env python3
import os
from google_auth_oauthlib.flow import InstalledAppFlow
from google.oauth2.credentials import Credentials
from google.auth.transport.requests import Request

# Replace this with your actual file paths
CRED_PATH = os.path.expanduser('~/credentials.json')  # Path to your 'credentials.json' file
TOKEN_PATH = os.path.expanduser('~/token.json')  # Path where the token will be saved

# The scope required for Google Photos
SCOPES = ['https://www.googleapis.com/auth/photoslibrary.readonly']

def authenticate():
    """Authenticate the user and save the refresh token."""
    creds = None
    if os.path.exists(TOKEN_PATH):
        creds = Credentials.from_authorized_user_file(TOKEN_PATH, SCOPES)

    # If credentials are invalid or expired, start the OAuth flow to reauthenticate
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())  # Try refreshing the token if expired
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                CRED_PATH, SCOPES
            )
            creds =

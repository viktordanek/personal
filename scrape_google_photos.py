#!/usr/bin/env python3
import os
import json
import uuid
from pathlib import Path
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
import git

SCOPES = ['https://www.googleapis.com/auth/photoslibrary.readonly']
TOKEN_PATH = Path.home() / 'token.json'
CRED_PATH = Path.home() / 'credentials.json'
GIT_REPO_PATH = Path.home() / 'repository'
PHOTO_METADATA_PATH = GIT_REPO_PATH / 'metadata'

def get_service():
    """Authenticate with Google Photos API and return the service."""
    if TOKEN_PATH.exists():
        creds = Credentials.from_authorized_user_file(str(TOKEN_PATH), SCOPES)
    else:
        flow = InstalledAppFlow.from_client_secrets_file(
            CRED_PATH,
            scopes=['https://www.googleapis.com/auth/photoslibrary.readonly']
        )
        creds = flow.run_console()
        service = build('photoslibrary', 'v1', credentials=creds)
        return service

def scrape():
    """Scrape Google Photos metadata and store it in a Git repository."""
    service = get_service()

    # Initialize Git repository if not already initialized
    if not GIT_REPO_PATH.exists():
        GIT_REPO_PATH.mkdir(parents=True)
        git.Repo.init(GIT_REPO_PATH)

    PHOTO_METADATA_PATH.mkdir(parents=True, exist_ok=True)

    repo = git.Repo(GIT_REPO_PATH)

    seen_google_ids = {
        json.loads(open(f).read())['google_photo_id']
        for f in PHOTO_METADATA_PATH.glob('*.json')
    }

    next_page_token = None
    while True:
        results = service.mediaItems().list(
            pageSize=100, pageToken=next_page_token
        ).execute()

        items = results.get('mediaItems', [])
        for item in items:
            google_id = item['id']
            if google_id in seen_google_ids:
                continue

            metadata = {
                'google_photo_id': google_id,
                'source': 'google_photos',
                'labels': []
            }

            file_id = str(uuid.uuid4())
            metadata_file = PHOTO_METADATA_PATH / f'{file_id}.json'
            with open(metadata_file, 'w') as f:
                json.dump(metadata, f, indent=2)

        next_page_token = results.get('nextPageToken')
        if not next_page_token:
            break

    repo.git.add(A=True)
    repo.index.commit("Update photo metadata")
    try:
        repo.remotes.origin.push()
    except Exception:
        pass  # Handle case where no remote is configured

if __name__ == '__main__':
    scrape()

# ``MyMusic/MyMusicAPI``

This is the summary for class MyMusicAPI

## Overview

This is the overview for class MyMusicAPI

## Topics

### Initiators

- ``init()``

- ``shared``

### Instance Properties

- ``fileRootURL``

- ``serverURL``

### Server status

- ``getServerStatus()``

### Albums

- ``getAlbums(fields:offset:limit:)``

- ``head(albumId:)``

- ``get(albumId:)``

- ``post(album:skipFiles:)``

- ``put(album:skipFiles:)``

- ``delete(albumId:)``

### Album Files

- ``get(albumId:filename:)``

- ``post(album:filename:)``

- ``post(albumId:filename:data:)``

- ``put(album:filename:)``

- ``put(albumId:filename:data:)``

- ``delete(albumId:filename:)``

### Singles

- ``getSingles(fields:offset:limit:)``

- ``head(singleId:)``

- ``get(singleId:)``

- ``post(single:skipFiles:)``

- ``put(single:skipFiles:)``

- ``delete(singleId:)``

### Single Files

- ``get(singleId:filename:)``

- ``post(single:filename:)``

- ``put(single:filename:)``

- ``post(singleId:filename:data:)``

- ``put(singleId:filename:data:)``

- ``delete(singleId:filename:)``

### Playlists

- ``getPlaylists(fields:offset:limit:)``

- ``head(playlistId:)``

- ``get(playlistId:)``

- ``post(playlist:)``

- ``put(playlist:)``

- ``delete(playlistId:)``

### Transactions

- ``getTransactions(startTime:)``


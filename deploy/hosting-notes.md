# Hosting Notes

## games.atla.in

- Serve the exported Godot web build from `deploy/web/`
- Point the `games.atla.in` subdomain DNS to the chosen static host
- Keep the web build at the root of the subdomain for the first release

## atla.in tile

- Add a launcher tile that links to `https://games.atla.in`
- The tile should show the game title, a short description, and a visual
  thumbnail or icon
- This repo currently contains a starter tile snippet at
  `deploy/atla-in-tile.html`


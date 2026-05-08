# Systems Index

## Systems

| System | Category | Description | Source |
| --- | --- | --- | --- |
| Grid Movement | Foundation | Moves pieces on a grid in response to swipe input. | Explicit |
| Puzzle Rules | Core | Stores the movement rules shown to the player for each puzzle. | Explicit |
| Lie Rule Selection | Core | Chooses which rule is false for a given puzzle. | Explicit |
| Lie Detection | Core | Determines when the player has identified the false rule. | Explicit |
| Score Tracking | Core | Tracks moves to catch the lie and puzzle performance. | Explicit |
| Rule Display UI | Presentation | Shows the current movement rules in a readable form. | Explicit |
| Puzzle Board UI | Presentation | Displays the grid and piece positions clearly. | Explicit |
| Result Screen | Presentation | Reveals solve result, false rule, and performance at completion. | Implicit |
| Puzzle Content Authoring | Feature | Lets designers create and tune handcrafted puzzles. | Implicit |
| Export / Hosting Shell | Polish | Packages the project for web build and deployment. | Implicit |

## Dependency Order

1. Grid Movement
2. Puzzle Rules
3. Lie Rule Selection
4. Lie Detection
5. Score Tracking
6. Puzzle Board UI
7. Rule Display UI
8. Result Screen
9. Puzzle Content Authoring
10. Export / Hosting Shell


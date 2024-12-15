# lmm
## INFO PROJET INSA

#### Guide d'utilisation du programme

------------


Le programme dépend des bibliothèques SDL2, SDL2_image et SDL2_ttf ainsi avant de commencer, verifiez bien que ces dernières soient bien installé.

------------



Pour commencer veuillez compiler le fichier main.pas via l'invite de commande avec la fonction `fpc main.pas` dans le répertoire ou ce situe le dossier,  puis executer le programme avec `./main`.

Une fois executer vous aurez le choix entre 2 actions: Quitter le jeu ou Jouer,  pour quitter appuyer sur `Leave`, pour jouer cliquer sur `Play`,  si vous decidez de jouer vous pourrez ensuite créer un nouveau monde en appuyant sur `New World`, vous devrez ensuite taper le nom désirer de votre monde, cela fait appuyer sur `Create` pour valider votre choix de nom et commencer là jouer. Si des mondes existais déjà alors il vous sera possible de rejoindre un monde pre-éxistant en appuyant sur son bouton correspond dans la liste. si trop de monde existe il est possible d'en supprimer en cliquant sur le bouton rouge à côté du nom du monde puis en cliquant sur `Yes`.
Une fois en jeu il vous sera possible de vous deplacer avec z,q,d,f:
- `z` - vous fait sauter.
- `q` - vous fait déplacer vers la gauche si possible.
- `d` - vous fait déplacer vers la droite si possible.
- `f`- vous fait attaquer en face de vous.

Il vous sera aussi possible d'intéragire avec le monde autour de vous à l'aide de la souris (ou pavet tactile):
- `clique droite` - casser un block si il y en a un.
- `clique gauche` - pose le block séléctionné.
- `molette haut/bas` - change le block séléctionné.

Attention de dangereux rats se baladent librement dans le monde si vous les voyez vous pouvez vous défendre en l'attaquant (touche f), si par malheur ce féroce énemie viens à bout de vous et de vos 100hp alors votre monde sera détruit et votre progressions perdu vous devrez alors créée un nouveau monde. 
Si vous souhaitez quitter le jeu il vous faudra appuyez sur `Esc`  puis cliquer sur `Leave` puis `Leave` un seconde fois pour fermer le programme.
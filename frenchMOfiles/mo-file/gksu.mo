��    %      D  5   l      @     A  s   C    �  �   �  �   U  �     k   �  �   7  k   �  N   \  _   �  E   	  &   Q	  '   x	  '   �	  (   �	  �   �	  _   �
  �   )     �     �     �            E   3  ,   y  +   �  %   �     �            +        C  	   [     e     r  f  �     �  �   �  4  u  �   �  �   T  �   T  n   �  �   [  �   A  c   �  i   +  a   �  2   �  =   *  9   h  =   �    �  l   �  �   a     E     W     q  "   �      �  ]   �  4   %  .   Z  )   �     �     �  	   �  5   �       
   >  &   I     p                          	      !      $                                       "                               %                                    
                    #               
   --debug, -d
    Print information on the screen that might be
    useful for diagnosing and/or solving problems.
   --description <description|file>, -D <description|file>
    Provide a descriptive name for the command to
    be used in the default message, making it nicer.
    You can also provide the absolute path for a
    .desktop file. The Name key for will be used in
    this case.
   --disable-grab, -g
    Disable the "locking" of the keyboard, mouse,
    and focus done by the program when asking for
    password.
   --login, -l
    Make this a login shell. Beware this may cause
    problems with the Xauthority magic. Run xhost
    to allow the target user to open windows on your
    display!
   --message <message>, -m <message>
    Replace the standard message shown to ask for
    password for the argument passed to the option.
    Only use this if --description does not suffice.
   --preserve-env, -k
    Preserve the current environments, does not set $HOME
    nor $PATH, for example.
   --print-pass, -p
    Ask gksu to print the password to stdout, just
    like ssh-askpass. Useful to use in scripts with
    programs that accept receiving the password on
    stdin.
   --prompt, -P
    Ask the user if they want to have their keyboard
    and mouse grabbed before doing so.
   --su-mode, -w
    Make GKSu use su, instead of using libgksu's
    default.
   --sudo-mode, -S
    Make GKSu use sudo instead of su, as if it had been
    run as "gksudo".
   --user <user>, -u <user>
    Call <command> as the specified user.
 <b>Failed to request password.</b>

%s <b>Failed to run %s as user %s.</b>

%s <b>Incorrect password... try again.</b> <b>Options to use when changing user</b> <b>Would you like your screen to be "grabbed"
while you enter the password?</b>

This means all applications will be paused to avoid
the eavesdropping of your password by a a malicious
application while you type it. <big><b>Missing options or arguments</b></big>

You need to provide --description or --message. <big><b>Unable to determine the program to run.</b></big>

The item you selected cannot be open with administrator powers because the correct application cannot be determined. Advanced options As user: GKsu version %s

 Missing command to run. Open as administrator Opens a terminal as the root user, using gksu to ask for the password Opens the file with administrator privileges Option not accepted for --disable-grab: %s
 Option not accepted for --prompt: %s
 Root Terminal Run program Run: Usage: %s [-u <user>] [options] <command>

 User %s does not exist. _Advanced _login shell _preserve environment Project-Id-Version: gksu 1.2.4
Report-Msgid-Bugs-To: kov@debian.org
POT-Creation-Date: 2007-05-11 00:59-0300
PO-Revision-Date: 2006-09-15 22:50+0200
Last-Translator: Thomas Huriaux <thomas.huriaux@gmail.com>
Language-Team: French <debian-l10n-french@lists.debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
 
   --debug, -d
    Affiche à l'écran des informations pouvant être utiles 
    au diagnostic ou à la résolution de problèmes.
   --description <description|fichier>, -D <description|fichier>
    Fournit pour la commande,  un nom descriptif qui sera utilisé
    comme message par défaut. Vous avez aussi la possibilité 
    d'indiquer le chemin absolu vers le fichier .desktop. Le nom
    de la clef sera alors utilisé dans ce cas.
   --disable-grab, -g
    Désactive le « verrouillage » du clavier, de la souris
    et du focus effectué par le programme lors de la 
    demande d'un mot de passe.
   --login, -l
    Se connecte dans un interpréteur de commmandes. Faîtes 
    attention, ceci peut créer des problèmes avec la magie
    Xauthority. Vous pouvez lancer xhost pour autoriser un
    utilisateur à ouvrir des fenêtres sur votre écran !
   --message <message>, -m <message>
    Remplace le message affiché habituellement pour demander 
    un mot de passe, par celui fournit en argument.
   --preserve-env, -k
    Préserve l'environnement courant, ne positionne pas $HOME
    ni $PATH par exemple.
   --print-pass, -p
    Demande à gksu d'imprimer le mot de passe sur la sortie
    standard (comme le fait ssh-askpass). Utile pour
    l'utilisation dans des scripts qui récupèrent le mot de
    passe sur l'entrée standard.
   --prompt, -P
    Demande à l'utilisateur s'il veut que le clavier et la 
    souris soient verrouillés avant de poser le verrou.
   --su-mode, -w
    Fait en sorte que GKsu utilise su, au lieu d'utiliser
    libgksu par défaut.
   --sudo-mode, -S
    Fait en sorte que GKSu utilise su, comme si « gksudo » avait
    été lancé.
   --user <utilisateur>, -u <utilisateur>
    Lance <commande> en tant qu'utilisateur renseigné.
 <b>Impossible de demander un mot de passe.</b>

%s <b>Impossible de lancer %s en tant qu'utilisateur %s.</b>

%s <b>Le mot de passe est incorrect. Essayez de nouveau.</b> <b>Options à utiliser lors d'un changement d'utilisateur</b> <b>Voulez-vous que votre écran soit verrouillé lors de la
saisie de votre mot de passe ?</b>

Ceci signifie que toutes les applications vont être mises
en pause afin d'éviter qu'une application malveillante ne
récupère votre mot de passe pendant que vous le saisissez. "<big><b>Options ou arguments manquants</b></big>

Il est nécessaire de fournir --description ou --message. <big><b>Impossible de déterminer le programme à lancer.</b></big>

L'élément que vous avez sélectionné ne peut être ouvert avec les droits administrateur parce que l'application appropriée n'a pas pu être déterminée. Options avancées En tant qu'utilisateur : GKsu version %s

 La commande à lancer est absente. Ouvrir en tant qu'administrateur Ouvrir un terminal en tant qu'administrateur, en utilisant gksu pour demander le mot de passe Ouvre le fichier avec les privilèges administrateur Option incompatible avec --disable-grab : %s
 Option incompatible avec  --prompt : %s
 Terminal administrateur Lancer le programme Lancer : Usage : %s [-u <utilisateur>] [options] <commande>

 L'utilisateur %s n'existe pas. _Avancées _interpréteur de commandes interactif _préserver l'environnement 
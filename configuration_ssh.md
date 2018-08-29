Configurer un accès ssh sur un serveur distant
1- Créer une clé ssh sur son ordi
2- Configurer le host sur son ordi
3- Ajouter une clé ssh en authorized_keys sur le host : cat path/id_rsa.pub >>~/.ssh/authorized_keys
4- Décommenter authorized_keys dans /etc/ssh/sshd_config du host
5- Redémarrer le service sshd avec systemctl : (sudo) sytemctl restart sshd
6- Se connceter sur son ordi avec : ssh <user>@hostname 
    Il n'y a plus besoin de mot de passe.

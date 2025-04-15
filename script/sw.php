<?php
ini_set('display_errors', 0);

// Définit l'en-tête pour indiquer que la réponse est au format JSON
header('Content-Type: application/json');

// Répertoire de base à analyser
$directory = '../';

// Fonction pour parcourir récursivement les fichiers et dossiers
function listFiles($dir) {
    $files = [];
    foreach (scandir($dir) as $file) {
        if ($file === '.' || $file === '..') {
            continue;
        }
        $path = $dir . $file;
        if (is_dir($path)) {
            // Appel récursif pour les sous-dossiers
            $files = array_merge($files, listFiles($path . '/'));
        } else {
            // Ajoute le chemin relatif du fichier
            $files[] = $path;
        }
    }
    return $files;
}

// Obtenir la liste des fichiers
$files = listFiles($directory);

// Nettoyer les chemins pour qu'ils soient relatifs
$cleanedFiles = array_map(function($file) {
    return str_replace('\/', '', $file); // Supprime './' pour des chemins propres
}, $files);

// Retourne la liste des fichiers sous forme de JSON
echo json_encode($cleanedFiles);

-- ============================================
-- TABLES PRINCIPALES
-- ============================================

-- Table des compagnies aériennes
CREATE TABLE Compagnie_Aerienne (
    id_compagnie SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    code_iata VARCHAR(3) UNIQUE,
    telephone VARCHAR(20),
    email VARCHAR(100)
);

-- Table des aéroports
CREATE TABLE Aeroport (
    id_aeroport SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    code_iata VARCHAR(3) UNIQUE NOT NULL,
    ville VARCHAR(100) NOT NULL,
    pays VARCHAR(100) NOT NULL,
    adresse VARCHAR(200),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des vols (améliorée)
CREATE TABLE Vol (
    id_vol SERIAL PRIMARY KEY,
    numero_vol VARCHAR(20) NOT NULL,
    id_compagnie INT REFERENCES Compagnie_Aerienne(id_compagnie),
    id_aeroport_depart INT REFERENCES Aeroport(id_aeroport),
    id_aeroport_arrivee INT REFERENCES Aeroport(id_aeroport),
    date_depart TIMESTAMP NOT NULL,
    date_atterrissage_prevue TIMESTAMP NOT NULL,
    date_atterrissage_reelle TIMESTAMP,
    terminal VARCHAR(10),
    porte VARCHAR(10),
    statut VARCHAR(20) CHECK (statut IN ('programmé', 'embarquement', 'décollé', 'atterri', 'annulé', 'retardé')) DEFAULT 'programmé',
    retard_minutes INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(numero_vol, date_depart)
);

-- Table des passagers (améliorée)
CREATE TABLE Passager (
    id_passager SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    telephone VARCHAR(20),
    email VARCHAR(100),
    nationalite VARCHAR(50),
    numero_passeport VARCHAR(50),
    langue_preferee VARCHAR(10) DEFAULT 'fr',
    besoins_speciaux TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table de liaison Vol-Passager (relation many-to-many)
CREATE TABLE Vol_Passager (
    id_vol_passager SERIAL PRIMARY KEY,
    id_vol INT REFERENCES Vol(id_vol) ON DELETE CASCADE,
    id_passager INT REFERENCES Passager(id_passager) ON DELETE CASCADE,
    numero_siege VARCHAR(10),
    classe VARCHAR(20) CHECK (classe IN ('économique', 'affaires', 'première')),
    nb_bagages INT DEFAULT 0,
    nb_bagages_cabine INT DEFAULT 0,
    statut_embarquement VARCHAR(20) CHECK (statut_embarquement IN ('enregistré', 'embarqué', 'non_présenté')) DEFAULT 'enregistré',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(id_vol, id_passager)
);

-- Table des chauffeurs (améliorée)
CREATE TABLE Chauffeur (
    id_chauffeur SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    telephone VARCHAR(20) NOT NULL,
    email VARCHAR(100),
    numero_permis VARCHAR(50) NOT NULL UNIQUE,
    date_expiration_permis DATE,
    langues_parlees VARCHAR(100),
    note_moyenne DECIMAL(3,2) DEFAULT 0.00,
    nb_trajets_effectues INT DEFAULT 0,
    disponibilite BOOLEAN DEFAULT TRUE,
    date_embauche DATE,
    statut VARCHAR(20) CHECK (statut IN ('actif', 'repos', 'congé', 'inactif')) DEFAULT 'actif',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des types de voiture
CREATE TABLE Type_Voiture (
    id_type SERIAL PRIMARY KEY,
    nom VARCHAR(50) NOT NULL UNIQUE,
    capacite_passagers INT NOT NULL,
    capacite_bagages INT NOT NULL,
    description TEXT,
    tarif_base DECIMAL(10,2)
);

-- Table des voitures (améliorée)
CREATE TABLE Voiture (
    id_voiture SERIAL PRIMARY KEY,
    immatriculation VARCHAR(20) NOT NULL UNIQUE,
    marque VARCHAR(50) NOT NULL,
    modele VARCHAR(50) NOT NULL,
    annee INT,
    couleur VARCHAR(30),
    id_type INT REFERENCES Type_Voiture(id_type),
    capacite_passagers INT NOT NULL,
    capacite_bagages INT NOT NULL,
    id_chauffeur INT REFERENCES Chauffeur(id_chauffeur) ON DELETE SET NULL,
    kilometrage INT DEFAULT 0,
    date_derniere_revision DATE,
    date_prochaine_revision DATE,
    statut VARCHAR(20) CHECK (statut IN ('disponible', 'en_service', 'maintenance', 'hors_service')) DEFAULT 'disponible',
    equipements TEXT[], -- climatisation, GPS, wifi, etc.
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des hôtels (améliorée)
CREATE TABLE Hotel (
    id_hotel SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    adresse VARCHAR(200) NOT NULL,
    ville VARCHAR(100) NOT NULL,
    code_postal VARCHAR(10),
    telephone VARCHAR(20),
    email VARCHAR(100),
    nb_etoiles INT CHECK (nb_etoiles BETWEEN 1 AND 5),
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    distance_aeroport_km DECIMAL(6,2),
    temps_trajet_moyen_minutes INT,
    contact_reception VARCHAR(100),
    instructions_acces TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des trajets (améliorée)
CREATE TABLE Trajet (
    id_trajet SERIAL PRIMARY KEY,
    id_vol INT REFERENCES Vol(id_vol),
    id_voiture INT REFERENCES Voiture(id_voiture) NOT NULL,
    id_chauffeur INT REFERENCES Chauffeur(id_chauffeur) NOT NULL,
    id_hotel INT REFERENCES Hotel(id_hotel),
    lieu_depart VARCHAR(200) NOT NULL,
    lieu_arrivee VARCHAR(200) NOT NULL,
    date_heure_depart TIMESTAMP NOT NULL,
    date_heure_arrivee_prevue TIMESTAMP,
    date_heure_arrivee_reelle TIMESTAMP,
    distance_km DECIMAL(6,2),
    duree_prevue_minutes INT,
    duree_reelle_minutes INT,
    nb_passagers INT DEFAULT 0,
    prix_total DECIMAL(10,2),
    statut VARCHAR(20) CHECK (statut IN ('planifié', 'assigné', 'en_attente', 'en_cours', 'terminé', 'annulé')) DEFAULT 'planifié',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des réservations (améliorée)
CREATE TABLE Reservation (
    id_reservation SERIAL PRIMARY KEY,
    numero_reservation VARCHAR(50) UNIQUE NOT NULL,
    id_trajet INT REFERENCES Trajet(id_trajet) ON DELETE CASCADE NOT NULL,
    id_passager INT REFERENCES Passager(id_passager) NOT NULL,
    id_hotel INT REFERENCES Hotel(id_hotel) NOT NULL,
    nb_bagages INT DEFAULT 0,
    heure_prise_en_charge TIMESTAMP,
    instructions_speciales TEXT,
    prix DECIMAL(10,2),
    statut VARCHAR(20) CHECK (statut IN ('en_attente', 'confirmée', 'en_cours', 'terminée', 'annulée', 'no_show')) DEFAULT 'en_attente',
    date_reservation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_confirmation TIMESTAMP,
    date_annulation TIMESTAMP,
    motif_annulation TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des évaluations
CREATE TABLE Evaluation (
    id_evaluation SERIAL PRIMARY KEY,
    id_trajet INT REFERENCES Trajet(id_trajet),
    id_passager INT REFERENCES Passager(id_passager),
    id_chauffeur INT REFERENCES Chauffeur(id_chauffeur),
    note_service INT CHECK (note_service BETWEEN 1 AND 5),
    note_conduite INT CHECK (note_conduite BETWEEN 1 AND 5),
    note_vehicule INT CHECK (note_vehicule BETWEEN 1 AND 5),
    note_ponctualite INT CHECK (note_ponctualite BETWEEN 1 AND 5),
    commentaire TEXT,
    date_evaluation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des notifications
CREATE TABLE Notification (
    id_notification SERIAL PRIMARY KEY,
    id_passager INT REFERENCES Passager(id_passager),
    id_chauffeur INT REFERENCES Chauffeur(id_chauffeur),
    id_trajet INT REFERENCES Trajet(id_trajet),
    type VARCHAR(50) NOT NULL, -- 'vol_retard', 'chauffeur_arrive', 'trajet_commence', etc.
    message TEXT NOT NULL,
    canal VARCHAR(20) CHECK (canal IN ('email', 'sms', 'push', 'app')),
    statut VARCHAR(20) CHECK (statut IN ('en_attente', 'envoyée', 'lue', 'échouée')) DEFAULT 'en_attente',
    date_envoi TIMESTAMP,
    date_lecture TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des paiements
CREATE TABLE Paiement (
    id_paiement SERIAL PRIMARY KEY,
    id_reservation INT REFERENCES Reservation(id_reservation),
    montant DECIMAL(10,2) NOT NULL,
    methode_paiement VARCHAR(30) CHECK (methode_paiement IN ('carte_bancaire', 'especes', 'virement', 'compte_entreprise')),
    statut VARCHAR(20) CHECK (statut IN ('en_attente', 'payé', 'échoué', 'remboursé')) DEFAULT 'en_attente',
    reference_transaction VARCHAR(100),
    date_paiement TIMESTAMP,
    date_remboursement TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- INDEX POUR OPTIMISATION
-- ============================================

CREATE INDEX idx_vol_date_arrivee ON Vol(date_atterrissage_prevue);
CREATE INDEX idx_vol_statut ON Vol(statut);
CREATE INDEX idx_vol_numero ON Vol(numero_vol);

CREATE INDEX idx_passager_email ON Passager(email);
CREATE INDEX idx_passager_telephone ON Passager(telephone);

CREATE INDEX idx_trajet_date_depart ON Trajet(date_heure_depart);
CREATE INDEX idx_trajet_statut ON Trajet(statut);
CREATE INDEX idx_trajet_chauffeur ON Trajet(id_chauffeur);
CREATE INDEX idx_trajet_voiture ON Trajet(id_voiture);

CREATE INDEX idx_reservation_statut ON Reservation(statut);
CREATE INDEX idx_reservation_numero ON Reservation(numero_reservation);

CREATE INDEX idx_chauffeur_disponibilite ON Chauffeur(disponibilite);
CREATE INDEX idx_voiture_statut ON Voiture(statut);

CREATE INDEX idx_notification_statut ON Notification(statut);
CREATE INDEX idx_notification_passager ON Notification(id_passager);

-- ============================================
-- TRIGGERS POUR MISE À JOUR AUTOMATIQUE
-- ============================================

-- Fonction pour mettre à jour updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers pour updated_at
CREATE TRIGGER update_vol_updated_at BEFORE UPDATE ON Vol FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_passager_updated_at BEFORE UPDATE ON Passager FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_chauffeur_updated_at BEFORE UPDATE ON Chauffeur FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_voiture_updated_at BEFORE UPDATE ON Voiture FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_trajet_updated_at BEFORE UPDATE ON Trajet FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_reservation_updated_at BEFORE UPDATE ON Reservation FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Fonction pour générer un numéro de réservation unique
CREATE OR REPLACE FUNCTION generate_numero_reservation()
RETURNS TRIGGER AS $$
BEGIN
    NEW.numero_reservation = 'RES' || TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDD') || '-' || LPAD(NEW.id_reservation::TEXT, 6, '0');
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER set_numero_reservation BEFORE INSERT ON Reservation FOR EACH ROW EXECUTE FUNCTION generate_numero_reservation();

-- ============================================
-- VUES UTILES
-- ============================================

-- Vue pour les trajets avec détails complets
CREATE VIEW v_trajets_details AS
SELECT 
    t.id_trajet,
    t.date_heure_depart,
    t.statut as statut_trajet,
    v.numero_vol,
    v.date_atterrissage_reelle,
    v.statut as statut_vol,
    vo.immatriculation,
    vo.modele as modele_voiture,
    c.nom || ' ' || c.prenom as nom_chauffeur,
    c.telephone as tel_chauffeur,
    h.nom as nom_hotel,
    h.adresse as adresse_hotel,
    COUNT(r.id_reservation) as nb_passagers_reserves
FROM Trajet t
LEFT JOIN Vol v ON t.id_vol = v.id_vol
LEFT JOIN Voiture vo ON t.id_voiture = vo.id_voiture
LEFT JOIN Chauffeur c ON t.id_chauffeur = c.id_chauffeur
LEFT JOIN Hotel h ON t.id_hotel = h.id_hotel
LEFT JOIN Reservation r ON t.id_trajet = r.id_trajet AND r.statut != 'annulée'
GROUP BY t.id_trajet, v.id_vol, vo.id_voiture, c.id_chauffeur, h.id_hotel;

-- Vue pour les chauffeurs disponibles
CREATE VIEW v_chauffeurs_disponibles AS
SELECT 
    c.*,
    vo.immatriculation,
    vo.modele,
    vo.capacite_passagers
FROM Chauffeur c
LEFT JOIN Voiture vo ON c.id_chauffeur = vo.id_chauffeur
WHERE c.disponibilite = TRUE 
  AND c.statut = 'actif'
  AND (vo.statut = 'disponible' OR vo.statut IS NULL);

-- ============================================
-- FONCTIONS UTILES
-- ============================================

-- Fonction pour calculer la note moyenne d'un chauffeur
CREATE OR REPLACE FUNCTION calculer_note_chauffeur(p_id_chauffeur INT)
RETURNS DECIMAL(3,2) AS $$
DECLARE
    v_note DECIMAL(3,2);
BEGIN
    SELECT AVG((note_service + note_conduite + note_vehicule + note_ponctualite) / 4.0)
    INTO v_note
    FROM Evaluation
    WHERE id_chauffeur = p_id_chauffeur;
    
    RETURN COALESCE(v_note, 0);
END;
$$ LANGUAGE plpgsql;
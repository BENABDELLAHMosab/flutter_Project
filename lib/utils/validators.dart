class Validators {
  static String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ce champ est requis';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez entrer votre nom complet';
    }
    if (value.trim().length < 3) {
      return 'Le nom doit contenir au moins 3 caractères';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez entrer un email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Veuillez entrer un email valide';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez entrer un mot de passe';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez confirmer le mot de passe';
    }
    if (value != password) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  static String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez entrer un prix';
    }
    if (double.tryParse(value) == null) {
      return 'Veuillez entrer un nombre valide';
    }
    return null;
  }

  static String? validateGuests(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez indiquer le nombre de personnes';
    }
    final guests = int.tryParse(value);
    if (guests == null || guests < 1) {
      return 'Nombre de personnes invalide';
    }
    return null;
  }

  static String? validateRooms(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez indiquer le nombre de chambres';
    }
    final rooms = int.tryParse(value);
    if (rooms == null || rooms < 1) {
      return 'Nombre de chambres invalide';
    }
    return null;
  }
}

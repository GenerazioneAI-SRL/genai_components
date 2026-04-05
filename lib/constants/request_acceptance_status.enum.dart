enum RequestAcceptanceStatus {
  PENDING,
  ACCEPTED,
  REJECTED;

  static RequestAcceptanceStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return RequestAcceptanceStatus.PENDING;
      case 'ACCEPTED':
        return RequestAcceptanceStatus.ACCEPTED;
      case 'REJECTED':
        return RequestAcceptanceStatus.REJECTED;
      default:
        throw ArgumentError('Status non valido: $status');
    }
  }

  String toBackendString() {
    return name;
  }

  String get label {
    switch (this) {
      case RequestAcceptanceStatus.PENDING:
        return 'In attesa';
      case RequestAcceptanceStatus.ACCEPTED:
        return 'Accettata';
      case RequestAcceptanceStatus.REJECTED:
        return 'Rifiutata';
    }
  }
}
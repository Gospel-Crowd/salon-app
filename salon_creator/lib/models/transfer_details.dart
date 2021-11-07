enum TransferStatus {
  Successful,
  Failed
}

class TransferDetails {
  final String id;
  final String fileId;
  final TransferStatus status;
  final String thumbnailUrl;

  TransferDetails({
    this.id,
    this.fileId,
    this.status,
    this.thumbnailUrl,
  });
}

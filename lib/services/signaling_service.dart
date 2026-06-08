import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../core/constants/app_constants.dart';

class SignalingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── CALLER: Room create karo + offer bhejo ───────────────────────────────
  Future<String> createRoom(RTCPeerConnection peerConnection) async {
    final roomRef = _db.collection(AppConstants.roomsCollection).doc();

    // ICE candidates collect karo aur Firestore mein save karo
    peerConnection.onIceCandidate = (candidate) {
      roomRef
          .collection(AppConstants.callerCandidates)
          .add(candidate.toMap());
    };

    // SDP Offer banao
    final offer = await peerConnection.createOffer();
    await peerConnection.setLocalDescription(offer);

    await roomRef.set({
      'offer': {'type': offer.type, 'sdp': offer.sdp},
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Callee ka answer aane ka wait karo
    roomRef.snapshots().listen((snapshot) async {
      final data = snapshot.data();
      if (data != null &&
          data['answer'] != null &&
          peerConnection.getRemoteDescription() == null) {
        final answer = RTCSessionDescription(
          data['answer']['sdp'],
          data['answer']['type'],
        );
        await peerConnection.setRemoteDescription(answer);
      }
    });

    // Callee ke ICE candidates listen karo
    roomRef
        .collection(AppConstants.calleeCandidates)
        .snapshots()
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data()!;
          peerConnection.addCandidate(RTCIceCandidate(
            data['candidate'],
            data['sdpMid'],
            data['sdpMLineIndex'],
          ));
        }
      }
    });

    return roomRef.id; // Room ID return karo — dusre ko share karo
  }

  // ─── CALLEE: Room join karo + answer bhejo ────────────────────────────────
  Future<void> joinRoom(
      String roomId, RTCPeerConnection peerConnection) async {
    final roomRef =
        _db.collection(AppConstants.roomsCollection).doc(roomId);
    final roomSnapshot = await roomRef.get();

    if (!roomSnapshot.exists) {
      throw Exception('Room not found: $roomId');
    }

    // ICE candidates collect karo
    peerConnection.onIceCandidate = (candidate) {
      roomRef
          .collection(AppConstants.calleeCandidates)
          .add(candidate.toMap());
    };

    // Caller ka offer set karo
    final data = roomSnapshot.data()!;
    final offer = RTCSessionDescription(
      data['offer']['sdp'],
      data['offer']['type'],
    );
    await peerConnection.setRemoteDescription(offer);

    // Answer banao
    final answer = await peerConnection.createAnswer();
    await peerConnection.setLocalDescription(answer);

    await roomRef.update({
      'answer': {'type': answer.type, 'sdp': answer.sdp},
    });

    // Caller ke ICE candidates listen karo
    roomRef
        .collection(AppConstants.callerCandidates)
        .snapshots()
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data()!;
          peerConnection.addCandidate(RTCIceCandidate(
            data['candidate'],
            data['sdpMid'],
            data['sdpMLineIndex'],
          ));
        }
      }
    });
  }

  // ─── Room cleanup ─────────────────────────────────────────────────────────
  Future<void> deleteRoom(String roomId) async {
    final roomRef =
        _db.collection(AppConstants.roomsCollection).doc(roomId);

    // Sub-collections bhi delete karo
    final callerCandidates =
        await roomRef.collection(AppConstants.callerCandidates).get();
    for (final doc in callerCandidates.docs) {
      await doc.reference.delete();
    }

    final calleeCandidates =
        await roomRef.collection(AppConstants.calleeCandidates).get();
    for (final doc in calleeCandidates.docs) {
      await doc.reference.delete();
    }

    await roomRef.delete();
  }
}

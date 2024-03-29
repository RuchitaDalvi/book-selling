import 'package:bookshop/models/cartModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cartProvider = StateNotifierProvider<CartProvider, List<CartModel>>(
    (ref) => CartProvider());
final cartStream =
    StreamProvider.autoDispose((ref) => CartProvider().getCartData());

class CartProvider extends StateNotifier<List<CartModel>> {
  CartProvider() : super([]);
  CollectionReference dbCart = FirebaseFirestore.instance.collection('cart');

  CollectionReference dbOrder = FirebaseFirestore.instance.collection('orders');

  Future<dynamic> addToCart(
    String cartId,
    int cartPrice,
    int cartQuantity,
    String totalPrice,
    String cartName,
    String cartImage,
  ) async {
    try {
      final response = await dbCart.add({
        'cartId': null,
        'cartPrice': cartPrice,
        'cartQuantity': cartQuantity,
        'totalPrice': totalPrice,
        'cartName': cartName,
        'cartImage': cartImage,
      });
      return 'success';
    } on FirebaseException catch (e) {
      print(e);
      return '';
    }
  }

  Future<dynamic> addOrder(List<String> productNames, int totalPrice) async {
    try {
      final response = await dbOrder.add({
        'totalPrice': totalPrice,
        'bookNames': productNames,
      });
      return 'success';
    } on FirebaseException catch (e) {
      print(e);
      return '';
    }
  }

  void addSingleCart(CartModel cartItem) {
    cartItem.cartQuantity = cartItem.cartQuantity + 1;
    cartItem.totalPrice = cartItem.cartPrice * (cartItem.cartQuantity + 1);
    state.add(cartItem);
  }

  Future<String> removePost(
      {required String cartId, required String cartImage}) async {
    try {
      final ref = FirebaseStorage.instance.ref().child('cart/$cartImage');
      await ref.delete();
      await dbCart.doc(cartId).delete();
      return 'success';
    } on FirebaseException catch (err) {
      print(err);
      return '';
    }
  }

  Stream<List<CartModel>> getCartData() {
    final data = dbCart.snapshots().map((event) => _getFromSnap(event));

    return data;
  }

  List<CartModel> _getFromSnap(QuerySnapshot querySnapshot) {
    return querySnapshot.docs.map((e) {
      final data = e.data() as Map<String, dynamic>;
      return CartModel(
        cartId: e.id,
        cartPrice: data['cartPrice'],
        cartQuantity: data['cartQuantity'],
        totalPrice: data['cartPrice'] * data['cartQuantity'],
        productId: data['productId'] ?? 'temporary',
        cartName: data["cartName"] ?? "",
        cartImage: data["cartImage"] ?? "",
      );
    }).toList();
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/merchants_provider.dart';
import '../models/merchant.dart';
import '../services/auth_service.dart';

class MerchantSearchScreen extends StatefulWidget {
  const MerchantSearchScreen({super.key});

  @override
  State<MerchantSearchScreen> createState() => _MerchantSearchScreenState();
}

class _MerchantSearchScreenState extends State<MerchantSearchScreen> {
  String _search = '';
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final merchantsProvider = Provider.of<MerchantsProvider>(context);
    final merchants = merchantsProvider.merchants
        .where((m) => m.name.toLowerCase().contains(_search.toLowerCase()))
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find merchant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add merchant',
            onPressed: () async {
              final name = await showDialog<String>(
                context: context,
                builder: (context) {
                  final addController = TextEditingController(text: _search);
                  return AlertDialog(
                    title: const Text('Add merchant'),
                    content: TextField(
                      controller: addController,
                      decoration: const InputDecoration(hintText: 'Merchant name'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, addController.text.trim()),
                        child: const Text('Add'),
                      ),
                    ],
                  );
                },
              );
              if (name != null && name.isNotEmpty) {
                final userId = await _getUserIdFromCognito();
                if (userId == null) return;
                final newMerchant = await merchantsProvider.createMerchant(name: name, userId: userId);
                if (newMerchant != null) {
                  Navigator.of(context).pop(newMerchant);
                }
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Merchant name',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    setState(() => _search = '');
                  },
                ),
              ),
              onChanged: (val) => setState(() => _search = val),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: merchants.isEmpty
                  ? Center(child: Text('No merchants found'))
                  : Wrap(
                      spacing: 8.0,
                      children: [
                        ...merchants.map((merchant) => ChoiceChip(
                              label: Text(merchant.name),
                              avatar: merchant.imageUrl.isNotEmpty
                                  ? CircleAvatar(backgroundImage: NetworkImage(merchant.imageUrl))
                                  : null,
                              selected: false,
                              onSelected: (selected) {
                                if (selected) {
                                  Navigator.of(context).pop(merchant);
                                }
                              },
                            )),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _getUserIdFromCognito() async {
    try {
      final userId = await AuthService.getUserId();
      return userId;
    } catch (e) {
      // Можно добавить обработку ошибки
      return null;
    }
  }
} 
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CategoryPickerDialog extends StatefulWidget {
  final String? selectedCategoryId;

  const CategoryPickerDialog({
    super.key,
    this.selectedCategoryId,
  });

  @override
  State<CategoryPickerDialog> createState() => _CategoryPickerDialogState();
}

class _CategoryPickerDialogState extends State<CategoryPickerDialog> {
  late Future<CategoriesResponse> _categoriesFuture;
  String _search = '';
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = ApiService.getCategories();
    _selectedId = widget.selectedCategoryId;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Select Category',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Поиск
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              ),
              onChanged: (v) => setState(() => _search = v.trim().toLowerCase()),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<CategoriesResponse>(
                future: _categoriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading categories',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _categoriesFuture = ApiService.getCategories();
                              });
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  final categories = snapshot.data?.categories ?? [];
                  if (categories.isEmpty) {
                    return const Center(child: Text('No categories available'));
                  }
                  // Фильтрация по поиску
                  final filtered = _search.isEmpty
                      ? categories
                      : categories.where((c) => c.name.toLowerCase().contains(_search)).toList();
                  // Группировка по groupName
                  final Map<String, List<CategoryData>> grouped = {};
                  for (final c in filtered) {
                    grouped.putIfAbsent(c.groupName, () => []).add(c);
                  }
                  final sortedGroups = grouped.entries.toList()
                    ..sort((a, b) => a.value.first.groupIndex.compareTo(b.value.first.groupIndex));
                  if (filtered.isEmpty) {
                    return const Center(child: Text('No results'));
                  }
                  return Scrollbar(
                    child: ListView.builder(
                      itemCount: sortedGroups.length,
                      itemBuilder: (context, groupIdx) {
                        final groupName = sortedGroups[groupIdx].key;
                        final groupCats = sortedGroups[groupIdx].value;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                              child: Text(
                                groupName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: groupCats.length,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                childAspectRatio: 0.85,
                              ),
                              itemBuilder: (context, idx) {
                                final cat = groupCats[idx];
                                final isSelected = cat.id == _selectedId;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() => _selectedId = cat.id);
                                    Navigator.pop(context, cat);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.15) : Colors.transparent,
                                      border: Border.all(
                                        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                                        width: isSelected ? 2 : 1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        cat.imageUrl != null && cat.imageUrl!.isNotEmpty
                                            ? Image.network(
                                                cat.imageUrl!,
                                                width: 30,
                                                height: 30,
                                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.category, size: 30),
                                              )
                                            : const Icon(Icons.category, size: 30),
                                        Text(
                                          cat.name,
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                            color: isSelected ? Theme.of(context).colorScheme.primary : null,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            if (groupIdx < sortedGroups.length - 1) const Divider(height: 24),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
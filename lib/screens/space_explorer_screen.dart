import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/bootprint_models.dart';
import '../providers/bootprint_provider.dart';

class SpaceExplorerScreen extends StatefulWidget {
  const SpaceExplorerScreen({Key? key}) : super(key: key);

  @override
  State<SpaceExplorerScreen> createState() => _SpaceExplorerScreenState();
}

class _SpaceExplorerScreenState extends State<SpaceExplorerScreen> {
  late BootprintProvider _provider;
  bool _showImageAndFact = true;
  bool _showImageOnly = false;
  bool _showFactOnly = false;

  @override
  void initState() {
    super.initState();
    // Fetch data when screen initializes
    Future.microtask(() {
      _provider = Provider.of<BootprintProvider>(context, listen: false);
      _fetchInitialData();
    });
  }

  void _fetchInitialData() {
    if (_showImageAndFact) {
      _provider.fetchImageAndFact();
    } else if (_showImageOnly) {
      _provider.fetchImage();
    } else {
      _provider.fetchFact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Space Explorer'), elevation: 0),
      body: Consumer<BootprintProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Object selector dropdown
              _buildObjectSelector(provider),

              // Content type selector
              _buildContentTypeSelector(),

              // Main content area
              Expanded(child: _buildContent(provider)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () =>
                Provider.of<BootprintProvider>(
                  context,
                  listen: false,
                ).refreshData(),
        child: const Icon(Icons.refresh),
        tooltip: 'Get new space content',
      ),
    );
  }

  Widget _buildObjectSelector(BootprintProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      child: Row(
        children: [
          const Text(
            'Select Celestial Object:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButton<CelestialObject>(
              value: provider.selectedObject,
              isExpanded: true,
              onChanged: (CelestialObject? newValue) {
                if (newValue != null) {
                  provider.setSelectedObject(newValue);
                  _fetchInitialData();
                }
              },
              items:
                  CelestialObject.values.map((CelestialObject object) {
                    return DropdownMenuItem<CelestialObject>(
                      value: object,
                      child: Text(
                        object.toString().split('.').last.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentTypeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildContentTypeButton(
            'Image & Fact',
            Icons.category,
            _showImageAndFact,
            () {
              setState(() {
                _showImageAndFact = true;
                _showImageOnly = false;
                _showFactOnly = false;
                _provider.fetchImageAndFact();
              });
            },
          ),
          _buildContentTypeButton(
            'Image Only',
            Icons.image,
            _showImageOnly,
            () {
              setState(() {
                _showImageAndFact = false;
                _showImageOnly = true;
                _showFactOnly = false;
                _provider.fetchImage();
              });
            },
          ),
          _buildContentTypeButton('Fact Only', Icons.info, _showFactOnly, () {
            setState(() {
              _showImageAndFact = false;
              _showImageOnly = false;
              _showFactOnly = true;
              _provider.fetchFact();
            });
          }),
        ],
      ),
    );
  }

  Widget _buildContentTypeButton(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color:
                  isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BootprintProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: ${provider.error}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchInitialData,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    // Build content based on selection
    if (_showImageAndFact && provider.currentImageFact != null) {
      return _buildImageAndFactContent(provider.currentImageFact!);
    } else if (_showImageOnly && provider.currentImage != null) {
      return _buildImageContent(provider.currentImage!);
    } else if (_showFactOnly && provider.currentFact != null) {
      return _buildFactContent(provider.currentFact!);
    } else {
      return const Center(
        child: Text('Select a celestial object and content type to explore'),
      );
    }
  }

  Widget _buildImageAndFactContent(SpaceImageFact data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildImageWidget(data.image),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.object.toUpperCase(),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(data.fact, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(Icons.photo, size: 16),
                      const SizedBox(width: 4),
                      Text('ID: ${data.imageId.substring(0, 8)}...'),
                      const SizedBox(width: 16),
                      const Icon(Icons.info, size: 16),
                      const SizedBox(width: 4),
                      Text('ID: ${data.factId.substring(0, 8)}...'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContent(SpaceImage data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildImageWidget(data.image),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.object.toUpperCase(),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Divider(),
                  Row(
                    children: [
                      const Icon(Icons.photo, size: 16),
                      const SizedBox(width: 4),
                      Text('Image ID: ${data.imageId.substring(0, 8)}...'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactContent(SpaceFact data) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.object.toUpperCase(),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  '"${data.fact}"',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(Icons.info, size: 16),
                    const SizedBox(width: 4),
                    Text('Fact ID: ${data.factId.substring(0, 8)}...'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder:
              (context, url) => Container(
                color: Colors.grey.shade200,
                child: const Center(child: CircularProgressIndicator()),
              ),
          errorWidget:
              (context, url, error) => Container(
                color: Colors.grey.shade200,
                child: const Center(child: Icon(Icons.error, size: 48)),
              ),
        ),
      ),
    );
  }
}

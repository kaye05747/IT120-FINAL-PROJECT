import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final List<Map<String, String>> flowerClasses = [
    {
      'name': 'Angraecum',
      'image': 'assets/images/Angraecum.jpg',
      'description': 'Elegant orchids known for their star-shaped white flowers and nocturnal fragrance.',
    },
    {
      'name': 'Brassavola',
      'image': 'assets/images/brassavola.jpg',
      'description': 'Fragrant orchids with distinctive lip structure and long-lasting blooms.',
    },
    {
      'name': 'Cattleya',
      'image': 'assets/images/Cattleya.jpg',
      'description': 'Classic orchids with large, showy flowers and rich colors.',
    },
    {
      'name': 'Epidendrum',
      'image': 'assets/images/epidendrum.jpg',
      'description': 'Diverse orchid genus with vibrant, reed-like stems and numerous flower clusters.',
    },
    {
      'name': 'Lycaste',
      'image': 'assets/images/Lycaste.jpg',
      'description': 'Deciduous orchids producing spectacular, fragrant flowers.',
    },
    {
      'name': 'Masdevallia',
      'image': 'assets/images/Masdevallia.jpg',
      'description': 'Small to medium-sized orchids with uniquely shaped, colorful flowers.',
    },
    {
      'name': 'Paphiopedilum',
      'image': 'assets/images/Paphiopedilum.jpg',
      'description': 'Lady\'s slipper orchids with distinctive pouch-like lips.',
    },
    {
      'name': 'Phalaenopsis',
      'image': 'assets/images/phalaenopsis.jpg',
      'description': 'Popular moth orchids with graceful, arching sprays of blooms.',
    },
    {
      'name': 'Vanda',
      'image': 'assets/images/vanda.jpg',
      'description': 'Epiphytic orchids with stunning, flat-faced flowers in vibrant colors.',
    },
    {
      'name': 'Zygopetalum',
      'image': 'assets/images/zygopetalum.jpg',
      'description': 'Fragrant orchids known for their striking, patterned petals.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Colors.pink,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Flower Classification',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.pink.shade400,
                      Colors.pink.shade600,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.local_florist,
                    size: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.pink.shade50, Colors.pink.shade100],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: Colors.pink.shade700,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'About This App',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Discover and identify beautiful orchid species using advanced AI technology. '
                          'Simply capture or upload a photo, and our intelligent system will instantly '
                          'recognize the flower type with high accuracy.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildFeatureChip(
                              icon: Icons.camera_alt,
                              label: 'Camera Capture',
                            ),
                            const SizedBox(width: 8),
                            _buildFeatureChip(
                              icon: Icons.photo_library,
                              label: 'Gallery Upload',
                            ),
                            const SizedBox(width: 8),
                            _buildFeatureChip(
                              icon: Icons.analytics,
                              label: 'AI Powered',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Supported Flower Classes',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final flower = flowerClasses[index];
                  return _buildFlowerCard(flower);
                },
                childCount: flowerClasses.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.pink.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.pink.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowerCard(Map<String, String> flower) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.pink.shade100, Colors.pink.shade200],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Image.asset(
                  flower['image']!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.pink.shade100, Colors.pink.shade200],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.local_florist,
                            size: 40,
                            color: Colors.pink.shade300,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            flower['name']!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.pink.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flower['name']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        flower['description']!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

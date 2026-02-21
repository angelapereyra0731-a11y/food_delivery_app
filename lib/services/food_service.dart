import '../models/food_item.dart';

class FoodService {
  static List<FoodItem> getAllItems() {
    return [
      FoodItem(
        id: '1',
        name: 'Classic Burger',
        description: 'Juicy beef patty with lettuce, tomato, and cheese',
        price: 189.00,
        category: 'Burgers',
        imagePlaceholder: 'FF6B35',
      ),
      FoodItem(
        id: '2',
        name: 'Pepperoni Pizza',
        description: 'Crispy crust with tomato sauce and pepperoni',
        price: 349.00,
        category: 'Pizza',
        imagePlaceholder: 'E63946',
      ),
      FoodItem(
        id: '3',
        name: 'Chicken Alfredo',
        description: 'Creamy pasta with grilled chicken strips',
        price: 245.00,
        category: 'Pasta',
        imagePlaceholder: 'F4A261',
      ),
      FoodItem(
        id: '4',
        name: 'Caesar Salad',
        description: 'Romaine lettuce, croutons, parmesan, caesar dressing',
        price: 155.00,
        category: 'Salads',
        imagePlaceholder: '2D6A4F',
      ),
      FoodItem(
        id: '5',
        name: 'Fish & Chips',
        description: 'Beer-battered fish fillet with crispy fries',
        price: 275.00,
        category: 'Seafood',
        imagePlaceholder: '457B9D',
      ),
      FoodItem(
        id: '6',
        name: 'Spaghetti Bolognese',
        description: 'Rich meat sauce over al dente spaghetti',
        price: 220.00,
        category: 'Pasta',
        imagePlaceholder: 'C77DFF',
      ),
      FoodItem(
        id: '7',
        name: 'BBQ Ribs',
        description: 'Fall-off-the-bone ribs with smoky BBQ glaze',
        price: 445.00,
        category: 'Mains',
        imagePlaceholder: '9B2226',
      ),
      FoodItem(
        id: '8',
        name: 'Chocolate Lava Cake',
        description: 'Warm chocolate cake with molten center',
        price: 135.00,
        category: 'Desserts',
        imagePlaceholder: '6D4C41',
      ),
      FoodItem(
        id: '9',
        name: 'Mango Shake',
        description: 'Fresh mango blended with milk and ice',
        price: 89.00,
        category: 'Drinks',
        imagePlaceholder: 'FFBE0B',
      ),
      FoodItem(
        id: '10',
        name: 'Club Sandwich',
        description: 'Triple-decker with ham, turkey, bacon, and veggies',
        price: 195.00,
        category: 'Sandwiches',
        imagePlaceholder: 'A8DADC',
      ),
    ];
  }

  static List<String> getCategories() {
    return ['All', 'Burgers', 'Pizza', 'Pasta', 'Salads', 'Seafood', 'Mains', 'Desserts', 'Drinks', 'Sandwiches'];
  }
}
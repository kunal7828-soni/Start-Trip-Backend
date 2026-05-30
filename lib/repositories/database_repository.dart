import '../config/supabase/supabase_config.dart';
import '../models/booking_model.dart';
import '../models/bus_route_model.dart';
import '../models/saved_place_model.dart';
import '../models/train_route_model.dart';
import '../models/trip_model.dart';

/// Database Repository contracts definition for Supabase queries.
abstract class DatabaseRepository {
  // Trips
  Future<List<TripModel>> getUserTrips(String userId);
  Future<TripModel> createTrip(TripModel trip);

  // Train Routes
  Future<List<TrainRouteModel>> searchTrains(String source, String destination);

  // Bus Routes
  Future<List<BusRouteModel>> searchBuses(String source, String destination);

  // Saved Places
  Future<List<SavedPlaceModel>> getSavedPlaces(String userId);
  Future<void> savePlace(SavedPlaceModel place);

  // Bookings
  Future<List<BookingModel>> getUserBookings(String userId);
  Future<BookingModel> createBooking(BookingModel booking);
}

/// Supabase client execution for remote PostgreSQL queries.
class DatabaseRepositoryImpl implements DatabaseRepository {
  final _client = SupabaseConfig.client;

  @override
  Future<List<TripModel>> getUserTrips(String userId) async {
    final response = await _client
        .from('trips')
        .select()
        .eq('user_id', userId)
        .order('start_date', ascending: true);

    final List<dynamic> data = response;
    return data.map((e) => TripModel.fromMap(e)).toList();
  }

  @override
  Future<TripModel> createTrip(TripModel trip) async {
    final response = await _client
        .from('trips')
        .insert(trip.toMap())
        .select()
        .single();
    
    return TripModel.fromMap(response);
  }

  @override
  Future<List<TrainRouteModel>> searchTrains(String source, String destination) async {
    final response = await _client
        .from('train_routes')
        .select()
        .ilike('source_station', '%$source%')
        .ilike('destination_station', '%$destination%');

    final List<dynamic> data = response;
    return data.map((e) => TrainRouteModel.fromMap(e)).toList();
  }

  @override
  Future<List<BusRouteModel>> searchBuses(String source, String destination) async {
    final response = await _client
        .from('bus_routes')
        .select()
        .ilike('source', '%$source%')
        .ilike('destination', '%$destination%');

    final List<dynamic> data = response;
    return data.map((e) => BusRouteModel.fromMap(e)).toList();
  }

  @override
  Future<List<SavedPlaceModel>> getSavedPlaces(String userId) async {
    final response = await _client
        .from('saved_places')
        .select()
        .eq('user_id', userId);

    final List<dynamic> data = response;
    return data.map((e) => SavedPlaceModel.fromMap(e)).toList();
  }

  @override
  Future<void> savePlace(SavedPlaceModel place) async {
    await _client.from('saved_places').insert(place.toMap());
  }

  @override
  Future<List<BookingModel>> getUserBookings(String userId) async {
    final response = await _client
        .from('bookings')
        .select()
        .eq('user_id', userId)
        .order('booking_date', ascending: false);

    final List<dynamic> data = response;
    return data.map((e) => BookingModel.fromMap(e)).toList();
  }

  @override
  Future<BookingModel> createBooking(BookingModel booking) async {
    final response = await _client
        .from('bookings')
        .insert(booking.toMap())
        .select()
        .single();

    return BookingModel.fromMap(response);
  }
}

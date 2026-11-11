import 'package:reservaditos/core/http/api_exception.dart';
import 'package:reservaditos/features/areas/data/area_models.dart';
import 'package:reservaditos/features/areas/data/areas_repository.dart';
import 'package:reservaditos/features/standing/data/standing_repository.dart';

const anaProfile = ResidentProfile(
  id: 'ana-perez',
  name: 'Ana Pérez',
  apartment: '502',
  buildingName: 'Edificio Demo',
);

const demoAreas = [
  ResidentArea(
    id: 'grill',
    name: 'Parrilla',
    icon: 'flame',
    fee: 50,
    deposit: 100,
    total: 150,
    availableToday: true,
  ),
  ResidentArea(
    id: 'multipurpose-room',
    name: 'Salón de usos múltiples',
    icon: 'users',
    fee: 50,
    deposit: 100,
    total: 150,
    availableToday: true,
  ),
  ResidentArea(
    id: 'pool',
    name: 'Piscina',
    icon: 'waves',
    fee: 50,
    deposit: 100,
    total: 150,
    availableToday: false,
  ),
];

class FakeAreasRepository implements AreasRepository {
  FakeAreasRepository({this.areas = demoAreas, this.error});

  final List<ResidentArea> areas;
  final ApiException? error;

  @override
  Future<List<ResidentArea>> fetchAreas() async {
    if (error != null) throw error!;
    return areas;
  }

  @override
  Future<ResidentProfile> fetchProfile() async => anaProfile;
}

class FakeStandingRepository implements StandingRepository {
  FakeStandingRepository(this.standing);

  final Standing standing;
  int calls = 0;

  @override
  Future<Standing> fetchStanding() async {
    calls++;
    return standing;
  }
}

const upToDate = Standing(
  upToDate: true,
  overdueAmount: 0,
  oldestOverdueDate: null,
);

const overdue = Standing(
  upToDate: false,
  overdueAmount: 350,
  oldestOverdueDate: '2026-11-05',
);

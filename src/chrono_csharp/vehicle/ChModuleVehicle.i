//////////////////////////////////////////////////
//  
//   ChModuleVehicle.i
//
//   SWIG configuration file.
//   This is processed by SWIG to create the C#
//   wrappers for the Chrono::Vehicle module.
//
///////////////////////////////////////////////////


%module(directors="1") vehicle


// Turn on the documentation of members, for more intuitive IDE typing

%feature("autodoc", "1");
%feature("flatnested", "1");

// Turn on the exception handling to intercept C++ exceptions
%include "exception.i"

%exception {
  try {
    $action
  } catch (const std::exception& e) {
    SWIG_exception(SWIG_RuntimeError, e.what());
  }
}


// For optional downcasting of polimorphic objects:
%include "../chrono_downcast.i" 

// For supporting shared pointers:
%include <std_shared_ptr.i>



// Include C++ headers this way...

%{
#include <string>
#include <vector>

#include "chrono/core/ChQuaternion.h"
#include "chrono/core/ChVector.h"
#include "chrono/solver/ChSolver.h"

#include "chrono/physics/ChSystem.h"
#include "chrono/physics/ChShaft.h"
#include "chrono/physics/ChShaftsLoads.h"
#include "chrono/physics/ChBody.h"
#include "chrono/physics/ChBodyAuxRef.h"
#include "chrono/physics/ChMarker.h"
#include "chrono/physics/ChLink.h"
#include "chrono/physics/ChShaftsCouple.h"
#include "chrono/physics/ChLinkTSDA.h"
#include "chrono/physics/ChLinkRotSpringCB.h"
#include "chrono/physics/ChLoadsBody.h"
#include "chrono/physics/ChLoadsXYZnode.h"
#include "chrono/physics/ChPhysicsItem.h"

#include "chrono_vehicle/ChApiVehicle.h"
#include "chrono_vehicle/ChVehicle.h"
#include "chrono_vehicle/wheeled_vehicle/ChWheeledVehicle.h"
#include "chrono_vehicle/wheeled_vehicle/vehicle/WheeledVehicle.h"
#include "chrono_vehicle/ChSubsysDefs.h"
#include "chrono_vehicle/ChVehicleOutput.h"
#include "chrono_vehicle/ChVehicleModelData.h"
#include "chrono_vehicle/ChChassis.h"
#include "chrono_vehicle/ChPart.h"
#include "chrono_vehicle/ChWorldFrame.h"

#include "chrono_vehicle/ChPowertrain.h"

#include "chrono_vehicle/ChDriver.h"
#include "chrono_vehicle/ChTerrain.h"
#include "chrono_vehicle/wheeled_vehicle/ChWheel.h"
#include "chrono_vehicle/wheeled_vehicle/wheel/Wheel.h"
#include "chrono_vehicle/wheeled_vehicle/ChAxle.h"

#include "chrono_vehicle/wheeled_vehicle/ChBrake.h"
#include "chrono_vehicle/wheeled_vehicle/brake/ChBrakeSimple.h"
#include "chrono_vehicle/wheeled_vehicle/brake/BrakeSimple.h"

#include "chrono_models/ChApiModels.h"
#include "chrono_models/vehicle/ChVehicleModelDefs.h"

#include "chrono_thirdparty/rapidjson/document.h"
#include "Eigen/src/Core/util/Memory.h"
#include "chrono_models/vehicle/citybus/CityBus.h"

using namespace chrono;
using namespace chrono::vehicle;

using namespace chrono::vehicle::generic;
using namespace chrono::vehicle::hmmwv;
using namespace chrono::vehicle::sedan;
using namespace chrono::vehicle::citybus;
using namespace chrono::vehicle::man;
using namespace chrono::vehicle::uaz;

%}


// Undefine ChApi otherwise SWIG gives a syntax error
#define CH_VEHICLE_API 
#define ChApi
#define EIGEN_MAKE_ALIGNED_OPERATOR_NEW
#define CH_DEPRECATED(msg)
#define CH_MODELS_API



// workaround for trouble
//%ignore chrono::fea::ChContactNodeXYZ::ComputeJacobianForContactPart;


// Include other .i configuration files for SWIG. 
// These are divided in many .i files, each per a
// different c++ class, when possible.

%include "std_string.i"
////%include "std_wstring.i"
%include "std_vector.i"
%include "typemaps.i"
////%include "wchar.i"
////%include "python/cwstring.i"
%include "cstring.i"

// This is to enable references to double,int,etc. types in function parameters
%pointer_class(int,int_ptr);
%pointer_class(double,double_ptr);
%pointer_class(float,float_ptr);
%pointer_class(char,char_ptr);


%template(vector_int) std::vector<int>;
%template(vector_double) std::vector<double>;
%template(TerrainForces) std::vector<chrono::vehicle::TerrainForce>;
%template(WheelStates) std::vector<chrono::vehicle::WheelState>;
%template(ChWheelList) std::vector<std::shared_ptr<chrono::vehicle::ChWheel> > ;
%template(ChAxleList) std::vector<std::shared_ptr<chrono::vehicle::ChAxle> > ;


//////%feature("director") chrono::vehicle::ChVehicle;


//
// For each class, keep updated the  A, B, C sections: 
// 


//
// A- ENABLE SHARED POINTERS
//
// Note that this must be done for almost all objects (not only those that are
// handled by shered pointers in C++, but all their chidren and parent classes. It
// is enough that a single class in an inheritance tree uses %shared_ptr, and all other in the 
// tree must be promoted to %shared_ptr too).

//from core module:
%shared_ptr(chrono::ChFunction)
%shared_ptr(chrono::ChFrame<double>) 
%shared_ptr(chrono::ChFrameMoving<double>)
%shared_ptr(chrono::ChPhysicsItem)
%shared_ptr(chrono::ChNodeBase) 
%shared_ptr(chrono::ChNodeXYZ) 
%shared_ptr(chrono::ChTriangleMeshShape)
%shared_ptr(chrono::geometry::ChTriangleMeshConnected)
%shared_ptr(chrono::ChFunction_Recorder)
%shared_ptr(chrono::ChBezierCurve)
%shared_ptr(chrono::ChLinkMarkers)

/*
from this module: pay attention to inheritance in the model namespace (generic, sedan etc). 
If those classes are wrapped, their parents are marked as shared_ptr while they are not, SWIG can't hanlde them.
Before adding a shared_ptr, mark as shared ptr all its inheritance tree in the model namespaces
*/

%shared_ptr(chrono::vehicle::RigidTerrain::Patch)
%shared_ptr(chrono::vehicle::ChPart)
%shared_ptr(chrono::vehicle::ChWheel)
%shared_ptr(chrono::vehicle::Wheel)
%shared_ptr(chrono::vehicle::ChBrakeSimple)
%shared_ptr(chrono::vehicle::ChBrake)
%shared_ptr(chrono::vehicle::BrakeSimple)
%shared_ptr(chrono::vehicle::ChVehicle)
%shared_ptr(chrono::vehicle::ChAxle)
%shared_ptr(chrono::vehicle::ChWheeledVehicle)
%shared_ptr(chrono::vehicle::WheeledVehicle)


%shared_ptr(chrono::vehicle::LinearSpringForce)
%shared_ptr(chrono::vehicle::LinearDamperForce)
%shared_ptr(chrono::vehicle::LinearSpringDamperForce)
%shared_ptr(chrono::vehicle::LinearSpringDamperActuatorForce)
%shared_ptr(chrono::vehicle::MapSpringForce)
%shared_ptr(chrono::vehicle::MapSpringBistopForce)
%shared_ptr(chrono::vehicle::LinearSpringBistopForce)
%shared_ptr(chrono::vehicle::DegressiveDamperForce)
%shared_ptr(chrono::vehicle::MapDamperForce)
%shared_ptr(chrono::vehicle::MapSpringDamperActuatorForce)
%shared_ptr(chrono::vehicle::LinearSpringTorque)
%shared_ptr(chrono::vehicle::LinearDamperTorque)
%shared_ptr(chrono::vehicle::LinearSpringDamperTorque)
%shared_ptr(chrono::vehicle::LinearSpringDamperActuatorTorque)
%shared_ptr(chrono::vehicle::MapSpringTorque)
%shared_ptr(chrono::vehicle::MapDamperTorque)


//
// B- INCLUDE HEADERS
//
//
// 1) 
//    When including with %include all the .i files, make sure that 
// the .i of a derived class is included AFTER the .i of
// a base class, otherwise SWIG is not able to build the type
// infos. 
//
// 2)
//    Then, this said, if one member function in Foo_B.i returns
// an object of Foo_A.i (or uses it as a parameter) and yet you must %include
// A before B, ex.because of rule 1), a 'forward reference' to A must be done in
// B by. Seems that it is enough to write 
//  mynamespace { class myclass; }
// in the .i file, before the %include of the .h, even if already forwarded in .h

%import  "chrono_csharp/core/ChClassFactory.i"
%import  "chrono_csharp/core/ChObject.i"
%import  "chrono_csharp/core/ChPhysicsItem.i"
%import  "chrono_csharp/core/ChVector.i"
%import  "chrono_csharp/core/ChQuaternion.i"
%import  "chrono_csharp/core/ChCoordsys.i"
%import  "chrono_csharp/core/ChFrame.i"
%import  "chrono_csharp/core/ChFrameMoving.i"
%import  "chrono_csharp/core/ChTimestepper.i"
%import  "chrono_csharp/core/ChSystem.i"
%import  "chrono_csharp/core/ChAssembly.i"
%import  "chrono_csharp/core/ChCoordsys.i"
%import  "chrono_csharp/core/ChMatrix.i"
%import  "chrono_csharp/core/ChBodyFrame.i"
%import  "chrono_csharp/core/ChBody.i"
%import  "chrono_csharp/core/ChBodyAuxRef.i"
%import  "chrono_csharp/core/ChLinkBase.i"
%import  "chrono_csharp/core/ChLinkLock.i"
%import  "chrono_csharp/core/ChLinkTSDA.i"
%import  "chrono_csharp/core/ChLinkRSDA.i"
%import  "chrono_csharp/core/ChLoad.i"
%import  "chrono_csharp/core/ChShaft.i"
%import  "chrono_csharp/core/ChAsset.i"
%import  "chrono_csharp/core/ChAssetLevel.i"
%import  "chrono_csharp/core/ChVisualization.i"
%import  "../../chrono/motion_functions/ChFunction.h"
%import  "chrono_csharp/core/ChMaterialSurface.i"
%import  "../../chrono/fea/ChContinuumMaterial.h"
%import  "../../chrono/physics/ChPhysicsItem.h"
%import  "../../chrono/physics/ChNodeBase.h"
%import  "../../chrono/physics/ChBodyFrame.h"
%import  "../../chrono/physics/ChLinkBase.h"
%import  "chrono_csharp/core/ChTexture.i"
%import  "../../chrono/assets/ChTriangleMeshShape.h"

// TODO: 
//%include "rapidjson.i"

//%include "../../chrono_vehicle/ChApiVehicle.h"
%ignore chrono::vehicle::TrackedCollisionFamily::Enum;
%ignore chrono::vehicle::TrackedCollisionFamily::OutputInformation;
%ignore chrono::vehicle::TrackedCollisionFlag::Enum;
%include "../../chrono_vehicle/ChSubsysDefs.h"
%include "../chrono_models/vehicle/ChVehicleModelDefs.h"
//TODO: conversion from std::vectors of ChVehicleOutput
%include "../../chrono_vehicle/ChVehicleOutput.h"
%include "../../chrono_vehicle/ChVehicleModelData.h"
%include "../../chrono_vehicle/ChPart.h"
%include "../../chrono_vehicle/ChWorldFrame.h"
%include "ChPowertrain.i"
%include "ChChassis.i"
%include "../../chrono_vehicle/ChVehicle.h"
%include "ChDriver.i"
%include "ChTerrain.i"
//TODO: antirollbar


// Wheeled parts
%include "ChSuspension.i"
%include "ChDriveline.i"
%include "ChSteering.i"

%include "../../chrono_vehicle/wheeled_vehicle/ChWheel.h"
%include "../../chrono_vehicle/wheeled_vehicle/wheel/Wheel.h"
%include "chrono_csharp/models/WheelModels.i"

%include "../../chrono_vehicle/wheeled_vehicle/ChBrake.h"
%include "../../chrono_vehicle/wheeled_vehicle/brake/ChBrakeSimple.h"
%include "../../chrono_vehicle/wheeled_vehicle/brake/BrakeSimple.h"
%include "chrono_csharp/models/BrakeModels.i"

%include "ChTire.i"

%include "../../chrono_vehicle/wheeled_vehicle/ChAxle.h"

%include "../../chrono_vehicle/wheeled_vehicle/ChWheeledVehicle.h"
%include "../../chrono_vehicle/wheeled_vehicle/vehicle/WheeledVehicle.h"
%include "chrono_csharp/models/VehicleModels.i"

%include "vehicleUtils.i"

// Tracked vehicles are not going to be wrapped in the short term


//
// C- DOWNCASTING OF SHARED POINTERS
//

%DefSharedPtrDynamicDowncast(chrono::vehicle,ChSuspension, ChDoubleWishbone)
%DefSharedPtrDynamicDowncast(chrono::vehicle,ChSuspension, ChMacPhersonStrut)
//%DefSharedPtrDynamicDowncast(chrono::vehicle,ChSuspension, MacPhersonStrut)
%DefSharedPtrDynamicDowncast(chrono::vehicle,ChSuspension, ChLeafspringAxle)
//%DefSharedPtrDynamicDowncast(chrono::vehicle,ChSuspension, LeafspringAxle)
%DefSharedPtrDynamicDowncast(chrono::vehicle,ChSuspension, ChHendricksonPRIMAXX)
%DefSharedPtrDynamicDowncast(chrono::vehicle,ChSuspension, ChDoubleWishboneReduced)
%DefSharedPtrDynamicDowncast(chrono::vehicle,ChSuspension, ChMultiLink)
//%DefSharedPtrDynamicDowncast(chrono::vehicle,ChSuspension, MultiLink)
%DefSharedPtrDynamicDowncast(chrono::vehicle,ChSuspension, ChRigidPinnedAxle)
%DefSharedPtrDynamicDowncast(chrono::vehicle,ChSuspension, ChSemiTrailingArm)
//%DefSharedPtrDynamicDowncast(chrono::vehicle,ChSuspension, SemiTrailingArm)
%DefSharedPtrDynamicDowncast(chrono::vehicle,ChSuspension, ChRigidSuspension)
%DefSharedPtrDynamicDowncast(chrono::vehicle,ChSuspension, ChSolidAxle)
%DefSharedPtrDynamicDowncast(chrono::vehicle,ChSuspension, ChThreeLinkIRS)
%DefSharedPtrDynamicDowncast(chrono::vehicle,ChSuspension, ChToeBarLeafspringAxle)
//%DefSharedPtrDynamicDowncast(chrono::vehicle,ChSuspension, DoubleWishbone)
//%DefSharedPtrDynamicDowncast(chrono::vehicle,ChSuspension, DoubleWishboneReduced)
//%DefSharedPtrDynamicDowncast(chrono::vehicle,ChSuspension, HendricksonPRIMAXX)
//%DefSharedPtrDynamicDowncast(chrono::vehicle,ChSuspension, SolidAxle)
//%DefSharedPtrDynamicDowncast(chrono::vehicle,ChSuspension, ThreeLinkIRS)
//%DefSharedPtrDynamicDowncast(chrono::vehicle,ChSuspension, ToeBarLeafspringAxle)
%DefSharedPtrDynamicDowncast(chrono::vehicle,ChSuspension, ChSolidBellcrankThreeLinkAxle)
%DefSharedPtrDynamicDowncast(chrono::vehicle,ChSuspension, ChSolidThreeLinkAxle)
//%DefSharedPtrDynamicDowncast(chrono::vehicle,ChSuspension, SolidBellcrankThreeLinkAxle)
//%DefSharedPtrDynamicDowncast(chrono::vehicle,ChSuspension, SolidThreeLinkAxle)

%DefSharedPtrDynamicDowncast(chrono::vehicle,ChSteering, ChPitmanArm)
%DefSharedPtrDynamicDowncast(chrono::vehicle,ChSteering, ChPitmanArmShafts)
%DefSharedPtrDynamicDowncast(chrono::vehicle,ChSteering, ChRackPinion)
%DefSharedPtrDynamicDowncast(chrono::vehicle,ChSteering, ChRotaryArm)
%DefSharedPtrDynamicDowncast(chrono::vehicle,ChChassis, ChRigidChassis)

%DefSharedPtrDynamicDowncast(chrono::vehicle,ChTire, ChTMeasyTire)
%DefSharedPtrDynamicDowncast(chrono::vehicle,ChTire, ChRigidTire)
%DefSharedPtrDynamicDowncast(chrono::vehicle,ChTire, ChReissnerTire)
%DefSharedPtrDynamicDowncast(chrono::vehicle,ChTire, ChPacejkaTire)
%DefSharedPtrDynamicDowncast(chrono::vehicle,ChTire, ChPac89Tire)
%DefSharedPtrDynamicDowncast(chrono::vehicle,ChTire, ChLugreTire)
%DefSharedPtrDynamicDowncast(chrono::vehicle,ChTire, ChFialaTire)

%DefSharedPtrDynamicDowncast(chrono::vehicle,ChPowertrain, SimplePowertrain)
%DefSharedPtrDynamicDowncast(chrono::vehicle,ChPowertrain, SimpleMapPowertrain)
%DefSharedPtrDynamicDowncast(chrono::vehicle,ChPowertrain, SimpleCVTPowertrain)
%DefSharedPtrDynamicDowncast(chrono::vehicle,ChPowertrain, ShaftsPowertrain)

%DefSharedPtrDynamicDowncast(chrono::vehicle,ChDriveline, ChDrivelineWV)
%DefSharedPtrDynamicDowncast(chrono::vehicle,ChDriveline, ChShaftsDriveline2WD)
%DefSharedPtrDynamicDowncast(chrono::vehicle,ChDriveline, ChShaftsDriveline4WD)
%DefSharedPtrDynamicDowncast(chrono::vehicle,ChDriveline, ChSimpleDriveline)
%DefSharedPtrDynamicDowncast(chrono::vehicle,ChDriveline, ChSimpleDrivelineXWD)

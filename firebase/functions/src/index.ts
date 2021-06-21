import * as functions from "firebase-functions";

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
const doesImageExist = async (latitude: number, longitude: number): Promise<boolean> => {
    const mapDataResponse = await axios.get("https://maps.googleapis.com/maps/api/streetview/metadata", {
        params: {
            location: `${latitude},${longitude}`,
            key: functions.config().map_api_key,
        },
    });
    if (mapDataResponse.data["status"] === "OK") {
        return true;
    }
    return false;
};
});

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
const downloadImage = async (locationID: number, latitude: number, longitude: number, heading: number) => {
    if (!existsSync(resolve(tmpdir(), "gmaps_static_images", `${locationID}`))) {
        mkdirSync(resolve(tmpdir(), "gmaps_static_images", `${locationID}`));
    }
    const path = resolve(tmpdir(), "gmaps_static_images", `${locationID}`, `${heading}.jpeg`);
    const writer = createWriteStream(path);
    const response = await axios({
        url: "https://maps.googleapis.com/maps/api/streetview",
        params: {
            location: `${latitude},${longitude}`,
            size: "411x411",
            heading: heading,
            fov: 120,
            key: functions.config().map_api_key,
        },
        responseType: "stream",
        method: "GET",
    });

    response.data.pipe(writer);

    return new Promise((resolve, reject) => {
        writer.on("finish", resolve);
        writer.on("error", reject);
    });
};
});

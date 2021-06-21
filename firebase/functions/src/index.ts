import * as functions from "firebase-functions";
import axios from "axios";
// eslint-disable-next-line no-unused-vars
import { firestore, storage, initializeApp } from "firebase-admin";
import { createWriteStream, mkdirSync, existsSync } from "fs";
import { resolve } from "path";
import { tmpdir } from "os";
// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
initializeApp();

const doesImageExist = async (latitude: number, longitude: number): Promise<boolean> => {
    const mapDataResponse = await axios.get("https://maps.googleapis.com/maps/api/streetview/metadata", {
        params: {
            location: `${latitude},${longitude}`,
            key: functions.config().maps.api_key,
        },
    });
    console.log(mapDataResponse.data);

    if (mapDataResponse.data["status"] === "OK") {
        return true;
    }
    return false;
};

const downloadImage = async (locationID: number, latitude: number, longitude: number, heading: number) => {
    if (!existsSync(resolve(tmpdir(), `${locationID}`))) {
        mkdirSync(resolve(tmpdir(), `${locationID}`));
    }
    const path = resolve(tmpdir(), `${locationID}`, `${heading}.jpeg`);
    const writer = createWriteStream(path);
    const response = await axios({
        url: "https://maps.googleapis.com/maps/api/streetview",
        params: {
            location: `${latitude},${longitude}`,
            size: "411x411",
            heading: heading,
            fov: 120,
            key: functions.config().maps.api_key,
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

const uploadImage = async (locationID: number, heading: number) => {
    const bucket = storage().bucket();
    const responseFile = await bucket.upload(resolve(tmpdir(), `${locationID}`, `${heading}.jpeg`), {
        destination: `street_view_images/${locationID}/${heading}.jpeg`,
    });
    return responseFile[0].publicUrl();
};

// const updateDocument = () => {};

export const uploadImages = functions.firestore
    .document("locations/{locationId}")
    .onCreate(async (snapshot, context) => {
        const location: firestore.GeoPoint = snapshot.get("position").geopoint;
        const locationID = context.params.locationId;

        functions.logger.info("Started image upload for ", locationID);

        if (await doesImageExist(location.latitude, location.longitude)) {
            functions.logger.info("Image exists for", locationID);
            const headings = [0, 120, 240];
            const imageUrls = [];
            for (const heading of headings) {
                await downloadImage(locationID, location.latitude, location.longitude, heading);
                imageUrls.push(await uploadImage(locationID, heading));

                functions.logger.info("Image downloaded for", locationID, heading);
            }
            snapshot.ref.set(
                {
                    hasImages: true,
                    imageUrls,
                },
                { merge: true },
            );

            functions.logger.info("Document updated for", locationID);
        } else {
            functions.logger.info("Image doe not exist for", locationID);
        }
    });

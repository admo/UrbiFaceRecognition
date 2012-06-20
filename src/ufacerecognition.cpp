/*
var u = UFaceRecognition.new("/home/aoleksy/Workspace/pittpatt/pittpatt_5.2.2_amd64/models");
var c = UCamera.new(0);
u.train(c.image, "Adam Oleksy");
 */
#include <string>
#include <iostream>

#include <pittpatt_sdk.h>
#include <pittpatt_license.h>
#include <pittpatt_raw_image_io.h>

#include <urbi/uobject.hh>

using namespace std;
using namespace urbi;

/* For get_num_cpus() */
#if defined (WIN32)
#include <windows.h>
#elif defined (linux)
#include <sys/sysinfo.h>
#elif defined (__MACH__)
#include <sys/sysctl.h>
#endif

/* Returns the number of CPUs in the system */
int sdk_utils_get_num_cpus(void)
{
  int ncpu = 0;

#if defined (WIN32)
  SYSTEM_INFO sysInfo;
  GetSystemInfo (&sysInfo);
  ncpu = sysInfo.dwNumberOfProcessors;
#elif defined (linux) && !defined(ANDROID)
  ncpu = get_nprocs();
#elif defined (__MACH__)
  size_t size = sizeof(int);
  sysctlbyname("hw.ncpu", &ncpu, &size, NULL, (size_t)0);
#else
  ncpu = 1;
#endif

  if (ncpu < 2)
    ncpu = 1;

  return ncpu;
}

class UFaceRecognition: public UObject {
private:
	ppr_context_type mContext;
	ppr_gallery_type mGallery;

	int getNextFreeFaceId() const;
	int getNextFreeSubjectId() const;
	int getSubjectIdWithTag(const string&) const;

public:
	UFaceRecognition(const string&);
	void init(const string& modelPath);

	UList find(UImage);
	int findTag(const string&);
	bool train(UImage, const string&);

	virtual ~UFaceRecognition();
};

inline UFaceRecognition::UFaceRecognition(const string& name) :
		UObject(name) {
	UBindFunction(UFaceRecognition, init);
}

UFaceRecognition::~UFaceRecognition() {
	ppr_finalize_sdk();
}

void UFaceRecognition::init(const string& modelPath) {
	ppr_settings_type pprSettings(ppr_get_default_settings());
	pprSettings.detection.enable = 1;
	pprSettings.detection.min_size = 4;
	pprSettings.detection.adaptive_min_size = 0.01f;
	pprSettings.detection.threshold = -1.0f;
	pprSettings.detection.num_threads = sdk_utils_get_num_cpus();
	pprSettings.detection.detect_best_face_only = 1;
	pprSettings.detection.extract_thumbnails = 1;
	pprSettings.landmarks.enable = 1;
	pprSettings.recognition.enable_extraction = 1;
	pprSettings.recognition.enable_comparison = 1;
	pprSettings.recognition.automatically_extract_templates = 1;

	ppr_error_type pprError = ppr_initialize_sdk(modelPath.c_str(), my_license_id, my_license_key);
	if(pprError != PPR_SUCCESS) {
		ppr_finalize_sdk();
		throw runtime_error(ppr_error_message(pprError));
	}

	pprError = ppr_initialize_context(pprSettings, &mContext);
	if(pprError != PPR_SUCCESS) {
		ppr_finalize_sdk();
		throw runtime_error(ppr_error_message(pprError));
	}

	pprError = ppr_create_gallery(mContext, &mGallery);
	if(pprError != PPR_SUCCESS) {
		ppr_finalize_sdk();
		throw runtime_error(ppr_error_message(pprError));
	}

	UBindFunction(UFaceRecognition, find);
	UBindFunction(UFaceRecognition, train);
}

int UFaceRecognition::findTag(const string& name) {
	return -1;
}

bool UFaceRecognition::train(UImage uimage, const string& tag) {
	bool ret = false;

	if (uimage.imageFormat != IMAGE_RGB && uimage.imageFormat != IMAGE_GREY8)
		throw runtime_error("Wrong image type");

	ppr_image_type image;
	ppr_raw_image_type rawImage;

	rawImage.color_space = uimage.imageFormat == IMAGE_RGB ?  PPR_RAW_IMAGE_RGB24 :   PPR_RAW_IMAGE_GRAY8;
	rawImage.bytes_per_line = uimage.width * (uimage.imageFormat == IMAGE_RGB ?  3 : 1);
	rawImage.height = uimage.height;
	rawImage.width = uimage.width;
	rawImage.data = uimage.data;

	ppr_raw_image_io_write("test.jpg", rawImage);

	// TRY
	ppr_create_image(rawImage, &image);
	ppr_face_list_type faceList;
	ppr_detect_faces(mContext, image, &faceList);
	ppr_free_image(image);

	cerr << "faceList.length=" << faceList.length << endl;
	// TRY
	if (faceList.length == 1) {
		int hasTemplate;
		ppr_face_has_template(mContext, faceList.faces[0], &hasTemplate);

		if(hasTemplate) {
			int id = getSubjectIdWithTag(tag);
			ppr_add_face(mContext, &mGallery, faceList.faces[0], id, getNextFreeFaceId());
			ppr_set_subject_string(mContext, &mGallery, id, tag.c_str());

			ret = true;
		}
	}

	ppr_free_face_list(faceList);
	return ret;
}

UList UFaceRecognition::find(UImage) {
	UList tmp;

	return tmp;
}

int UFaceRecognition::getNextFreeFaceId() const {
	ppr_id_list_type idList;
	ppr_get_face_id_list(mContext, mGallery, &idList);
	int nextFreeFaceId = idList.length;
	ppr_free_id_list(idList);
	return nextFreeFaceId;
}

int UFaceRecognition::getNextFreeSubjectId() const {
	ppr_id_list_type idList;
	ppr_get_subject_id_list(mContext, mGallery, &idList);
	int nextFreeSubjectId = idList.length;
	ppr_free_id_list(idList);
	return nextFreeSubjectId;
}

int UFaceRecognition::getSubjectIdWithTag(const string &tag) const {
	ppr_id_list_type idList;
	ppr_get_subject_id_list(mContext, mGallery, &idList);

	int id;
	for (id = 0; id < idList.length; ++id) {
		ppr_string_type stringTag;
		ppr_get_subject_string(mContext, mGallery, idList.ids[id], &stringTag);
		if (string(stringTag.str) == tag)
			break;
	}

	ppr_free_id_list(idList);

	return id;
}

UStart(UFaceRecognition);

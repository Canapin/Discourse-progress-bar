import { apiInitializer } from "discourse/lib/api";
import ProgressBar from "../components/progress-bar";

export default apiInitializer((api) => {
  if (!settings.outlet_name) return;
  api.renderInOutlet(settings.outlet_name, ProgressBar);
});

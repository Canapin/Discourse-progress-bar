import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import willDestroy from "@ember/render-modifiers/modifiers/will-destroy";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import { defaultHomepage } from "discourse/lib/utilities";

export default class ProgressBar extends Component {
  @service router;
  @service site;
  
  @tracked current_value = settings.current_value;
  @tracked max_value = settings.max_value;
  @tracked hide_when_full = settings.hide_when_full;

  @action
  addBodyClass() {
    if (settings.outlet_name) {
      document.body.classList.add(`${settings.outlet_name}-progress-bar`);
    }
  }

  @action
  removeBodyClass() {
    if (settings.outlet_name) {
      document.body.classList.remove(`${settings.outlet_name}-progress-bar`);
    }
  }

  get contentBefore() {
    return htmlSafe(settings.content_before);
  }

  get contentAfter() {
    return htmlSafe(settings.content_after);
  }

  get hideWhenFull() {
    return !(this.hide_when_full && this.current_value >= this.max_value);
  }

  get showOnMobile() {
    return !this.site.mobileView || settings.display_on_mobile;
  }

  get percentage() {
    const current = parseFloat(this.current_value) || 0;
    const max = parseFloat(this.max_value) || 100;

    if (max === 0) return 0;
    return Math.round((current / max) * 100);
  }

  get displayProgressValue() {
    let progressValue = settings.value_display || "{percentage}%";
    
    progressValue = progressValue.replace(/{current}/g, this.current_value);
    progressValue = progressValue.replace(/{max}/g, this.max_value);
    progressValue = progressValue.replace(/{percentage}/g, this.percentage);

    return progressValue;
  }

  get showOnRoute() {
    const path = this.router.currentURL;

    if (
      settings.display_on_homepage &&
      this.router.currentRouteName === `discovery.${defaultHomepage()}`
    ) {
      return true;
    }

    if (settings.url_must_contain.length) {
      const allowedPaths = settings.url_must_contain.split("|");
      return allowedPaths.some((allowedPath) => {
        if (allowedPath.slice(-1) === "*") {
          return path.indexOf(allowedPath.slice(0, -1)) === 0;
        }
        return path === allowedPath;
      });
    }
  }

  get shouldShow() {
    return this.showOnRoute && this.hideWhenFull && this.showOnMobile;
  }

  <template>
    {{#if this.shouldShow}}
      <div class="progress-bar__component" 
        {{didInsert this.addBodyClass}}
        {{willDestroy this.removeBodyClass}}
      >
        <div class="progress-bar__wrap">
          <div class="progress-bar__before">
            {{{this.contentBefore}}}
          </div>
          <div class="progress-bar__data">
            <div class="progress-bar__container">
              <div class="progress-bar__bar"></div>
            </div>
            <div class="progress-bar__status">
              {{this.displayProgressValue}}
            </div>
          </div>
          <div class="progress-bar__after">
            {{{this.contentAfter}}}
          </div>
        </div>
      </div>
    {{/if}}
  </template>
}
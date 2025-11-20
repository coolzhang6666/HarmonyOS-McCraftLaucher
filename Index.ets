import { hilog } from '@kit.PerformanceAnalysisKit';
import testNapi from 'libentry.so';
import router from '@ohos.router';
import { window } from '@kit.ArkUI'; // window应该从ArkUI导入
import common from '@ohos.app.ability.common';
import display from '@ohos.display';

const DOMAIN = 0x0000;

@Entry
@Component
struct MinecraftLauncher {
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  @State currentVersion: string = "1.20.1"
  @State newsList: string[] = [
    "纯血鸿蒙启动器 - 专为HarmonyOS 6.0打造",
    "测试版本，只有UI",
    "版权所有 © coolzhang6666",
    "优化了横竖屏自适应体验,但横版还存在bug"
  ]
  // 响应式布局状态
  @State isLandscape: boolean = false
  @State windowWidth: number = 0
  @State windowHeight: number = 0

  aboutToAppear() {
    this.getWindowSize();
    // 监听窗口尺寸变化
    window.getLastWindow(this.context).then((win) => {
      win.on('windowSizeChange', (newSize) => {
        this.isLandscape = newSize.width > newSize.height;
        this.windowWidth = newSize.width;
        this.windowHeight = newSize.height;
      });
    }).catch((err: Error) => {
      hilog.error(DOMAIN, 'MinecraftLauncher', '监听窗口变化失败: %{public}s', err.message);
    });
  }

  onPageShow() {
    // 启用自动旋转
    window.getLastWindow(this.context).then((win) => {
      win.setPreferredOrientation(window.Orientation.AUTO_ROTATION)
        .then(() => {
          hilog.info(DOMAIN, 'Orientation', '自动旋转已启用');
        })
        .catch((err: Error) => {
          hilog.error(DOMAIN, 'Orientation', '方向设置失败: %{public}s', err.message);
        });
    }).catch((err: Error) => {
      hilog.error(DOMAIN, 'MinecraftLauncher', '获取窗口失败: %{public}s', err.message);
    });
  }

  async getWindowSize() {
    try {
      const win = await window.getLastWindow(this.context);
      const size = win.getWindowProperties().windowRect;
      this.windowWidth = size.width;
      this.windowHeight = size.height;
      // 添加设备物理方向检测
      const defaultDisplay = await display.getDefaultDisplay();
      this.isLandscape = defaultDisplay.orientation === display.Orientation.LANDSCAPE;
    } catch (error) {
      hilog.error(DOMAIN, 'MinecraftLauncher', '获取窗口尺寸失败: %{public}s', error.message);
    }
  }

  // 启动游戏方法
  private launchGame() {
    try {
      router.pushUrl({
        url: 'pages/GamePage'
      }, router.RouterMode.Standard, (err) => {
        if (err) {
          hilog.error(DOMAIN, 'MinecraftLauncher', '路由跳转失败: %{public}s', err.message);
        }
      });
    } catch (err) {
      hilog.error(DOMAIN, 'MinecraftLauncher', '启动游戏异常: %{public}s', err.message);
    }
  }

  // 打开版本设置
  private openVersionSettings() {
    hilog.info(DOMAIN, 'MinecraftLauncher', '打开版本设置');
    // TODO: 实现版本设置页面跳转
  }

  // 切换游戏版本
  private switchVersion() {
    hilog.info(DOMAIN, 'MinecraftLauncher', '切换游戏版本');
    // TODO: 实现版本切换逻辑
  }

  build() {
    Column() {
      // 1. 顶部状态栏 - 使用安全区域适配
      Row() {
        Text("欢迎，Steve")
          .fontColor($r('app.color.white'))
          .fontSize(this.isLandscape ? $r('app.float.font_size_large') : $r('app.float.font_size_medium'))
          .margin({ left: $r('app.float.margin_large') })

        Button("设置", { type: ButtonType.Capsule })
          .size({
            width: this.isLandscape ? $r('app.float.button_width_large') : $r('app.float.button_width_medium'),
            height: this.isLandscape ? $r('app.float.button_height_large') : $r('app.float.button_height_medium')
          })
          .fontSize(this.isLandscape ? $r('app.float.font_size_medium') : $r('app.float.font_size_small'))
          .fontColor($r('app.color.white'))
          .backgroundColor($r('app.color.primary'))
          .margin({ right: $r('app.float.margin_large') })
      }
      .width('100%')
      .height(this.isLandscape ? $r('app.float.header_height_landscape') : $r('app.float.header_height_portrait'))
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .padding({
        top: $r('app.float.safe_area_top'),
        left: $r('app.float.safe_area_left'),
        right: $r('app.float.safe_area_right')
      })

      // 2. 主体内容 - 根据横竖屏动态布局
      if (this.isLandscape) {
        this.buildLandscapeContent()
      } else {
        this.buildPortraitContent()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundBlurStyle(BlurStyle.Thin)
    .linearGradient({
      angle: 180,
      colors: [
        [$r('app.color.gradient_start'), 0.0],
        [$r('app.color.gradient_middle'), 0.5],
        [$r('app.color.gradient_end'), 1.0]
      ]
    })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }

  // 横屏布局
  @Builder
  buildLandscapeContent() {
    Row() {
      // 左侧功能区 (45%)
      Column() {
        // 游戏Logo
        Image($r('app.media.MCLlogo'))
          .size({
            width: $r('app.float.logo_size_landscape'),
            height: $r('app.float.logo_size_landscape')
          })
          .margin({ bottom: $r('app.float.margin_xlarge') })
          .objectFit(ImageFit.Contain)

        // 启动游戏按钮
        Button("启动游戏", { type: ButtonType.Capsule })
          .size({
            width: $r('app.float.main_button_width_landscape'),
            height: $r('app.float.main_button_height_landscape')
          })
          .fontSize($r('app.float.main_button_font_size'))
          .fontColor($r('app.color.white'))
          .backgroundColor($r('app.color.primary'))
          .margin({ bottom: $r('app.float.margin_large') })
          .onClick(() => this.launchGame())

        // 版本信息
        Text("当前版本：" + this.currentVersion)
          .fontColor($r('app.color.white'))
          .fontSize($r('app.float.font_size_medium'))
          .margin({ bottom: $r('app.float.margin_medium') })

        // 版本操作按钮行
        Row() {
          Button("版本设置", { type: ButtonType.Capsule })
            .layoutWeight(1)
            .height($r('app.float.secondary_button_height'))
            .fontSize($r('app.float.font_size_small'))
            .fontColor($r('app.color.white'))
            .backgroundColor($r('app.color.secondary'))
            .margin({ right: $r('app.float.margin_small') })
            .onClick(() => this.openVersionSettings())

          Button("版本切换", { type: ButtonType.Capsule })
            .layoutWeight(1)
            .height($r('app.float.secondary_button_height'))
            .fontSize($r('app.float.font_size_small'))
            .fontColor($r('app.color.white'))
            .backgroundColor($r('app.color.secondary'))
            .margin({ left: $r('app.float.margin_small') })
            .onClick(() => this.switchVersion())
        }
        .width($r('app.float.main_button_width_landscape'))
        .margin({ top: $r('app.float.margin_medium') })
        .justifyContent(FlexAlign.Center)
      }
      .width('45%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)

      // 右侧新闻区 (55%)
      Column() {
        Text("最新动态")
          .fontSize($r('app.float.section_title_font_size'))
          .fontColor($r('app.color.white'))
          .fontWeight(FontWeight.Bold)
          .margin({
            bottom: $r('app.float.margin_large'),
            top: $r('app.float.margin_medium'),
            left: $r('app.float.margin_large')
          })
          .alignSelf(ItemAlign.Start)

        List({ space: 8 }) {
          ForEach(this.newsList, (item: string, index?: number) => {
            ListItem() {
              Text(item)
                .fontColor($r('app.color.text_secondary'))
                .fontSize($r('app.float.font_size_medium'))
                .padding($r('app.float.list_item_padding'))
                .backgroundColor($r('app.color.list_item_background'))
                .borderRadius($r('app.float.border_radius_large'))
                .width('100%')
            }
          }, (item: string, index?: number) => index?.toString() ?? item)
        }
        .width('90%')
        .alignListItem(ListItemAlign.Center)
        .scrollBar(BarState.Auto)
        .layoutWeight(1)
        .margin({ bottom: $r('app.float.margin_medium') })
      }
      .width('55%')
      .height('100%')
      .backgroundColor($r('app.color.section_background'))
      .borderRadius($r('app.float.section_border_radius'))
      .margin({ right: $r('app.float.margin_large') })
      .padding({ bottom: $r('app.float.margin_medium') })
    }
    .width('100%')
    .height('100%')
    .margin({ top: $r('app.float.margin_medium') })
    .padding({ left: $r('app.float.margin_medium') })
  }

  // 竖屏布局
  @Builder
  buildPortraitContent() {
    Column() {
      // 上部功能区
      Column() {
        Image($r('app.media.MCLlogo'))
          .size({
            width: $r('app.float.logo_size_portrait'),
            height: $r('app.float.logo_size_portrait')
          })
          .margin({ bottom: $r('app.float.margin_large') })
          .objectFit(ImageFit.Contain)

        Button("启动游戏", { type: ButtonType.Capsule })
          .width('80%')
          .height($r('app.float.main_button_height_portrait'))
          .fontSize($r('app.float.main_button_font_size_portrait'))
          .fontColor($r('app.color.white'))
          .backgroundColor($r('app.color.primary'))
          .margin({ bottom: $r('app.float.margin_large') })
          .onClick(() => this.launchGame())

        Text("当前版本：" + this.currentVersion)
          .fontColor($r('app.color.white'))
          .fontSize($r('app.float.font_size_medium'))
          .margin({ bottom: $r('app.float.margin_medium') })

        Row() {
          Button("版本设置", { type: ButtonType.Capsule })
            .layoutWeight(1)
            .height($r('app.float.secondary_button_height'))
            .fontSize($r('app.float.font_size_small'))
            .fontColor($r('app.color.white'))
            .backgroundColor($r('app.color.secondary'))
            .margin({ right: $r('app.float.margin_small') })
            .onClick(() => this.openVersionSettings())

          Button("版本切换", { type: ButtonType.Capsule })
            .layoutWeight(1)
            .height($r('app.float.secondary_button_height'))
            .fontSize($r('app.float.font_size_small'))
            .fontColor($r('app.color.white'))
            .backgroundColor($r('app.color.secondary'))
            .margin({ left: $r('app.float.margin_small') })
            .onClick(() => this.switchVersion())
        }
        .width('80%')
        .margin({ top: $r('app.float.margin_medium') })
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)

      // 下部新闻区
      Column() {
        Text("最新动态")
          .fontSize($r('app.float.section_title_font_size_portrait'))
          .fontColor($r('app.color.white'))
          .fontWeight(FontWeight.Bold)
          .margin({
            bottom: $r('app.float.margin_medium'),
            top: $r('app.float.margin_small'),
            left: $r('app.float.margin_medium')
          })
          .alignSelf(ItemAlign.Start)

        List({ space: 8 }) {
          ForEach(this.newsList, (item: string, index?: number) => {
            ListItem() {
              Text(item)
                .fontColor($r('app.color.text_secondary'))
                .fontSize($r('app.float.font_size_small'))
                .padding($r('app.float.list_item_padding_portrait'))
                .backgroundColor($r('app.color.list_item_background'))
                .borderRadius($r('app.float.border_radius'))
                .width('100%')
            }
          }, (item: string, index?: number) => index?.toString() ?? item)
        }
        .width('100%')
        .layoutWeight(1)
        .alignListItem(ListItemAlign.Center)
      }
      .width('95%')
      .layoutWeight(1)
      .backgroundColor($r('app.color.section_background'))
      .borderRadius($r('app.float.section_border_radius'))
      .margin({
        top: $r('app.float.margin_medium'),
        bottom: $r('app.float.margin_medium')
      })
      .padding({
        left: $r('app.float.margin_small'),
        right: $r('app.float.margin_small'),
        bottom: $r('app.float.margin_small')
      })
    }
    .width('100%')
    .height('100%')
    .padding({
      left: $r('app.float.margin_medium'),
      right: $r('app.float.margin_medium')
    })
  }
}
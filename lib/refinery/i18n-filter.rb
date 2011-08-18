module RoutingFilter
  class RefineryLocales < Filter

    def around_recognize(path, env, &block)
      if ::Refinery::I18n.enabled?
        if path =~ %r{^/(#{::Refinery::I18n.locales.keys.join('|')})(/|$)}
          path.sub! %r(^/(([a-zA-Z\-_])*)(?=/|$)) do
            ::I18n.locale = $1
            ''
          end
          path.sub!(%r{^$}) { '/' }
        else
          ::I18n.locale = ::I18n.default_locale
        end
      end

      yield.tap do |params|
        params[:locale] = ::I18n.locale if ::Refinery::I18n.enabled?
        params
      end
    end

    def around_generate(params, &block)
      locale = params.delete(:locale) || ::I18n.locale

      yield.tap do |result|
        if false and
           locale != ::I18n.default_locale and
           result !~ %r{^/(wymiframe)} and
           Rails.env.development?
          result.sub!(%r(^(http.?://[^/]*)?(.*))) { "#{$1}/#{locale}#{$2}" }
        end

        result
      end 
    end

  end
end
